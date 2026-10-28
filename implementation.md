# Implementation plan: debt, complexity and bugs

Result of a full read of `OpenWorkouts/`, `OpenWorkoutsTests/`, `project.yml` and `documentation/` (2026-10-28).
Nothing here is implemented yet. Items are ranked by user impact. Each fix ships with tests and a doc update (AGENTS.md rules 3 and 4).

Legend: **Bug** = wrong behaviour today. **Debt** = works, but will cost later. **Simplify** = less code, same behaviour.

---

## P1: Bugs that break a core promise

### 1. Workouts never reach Apple Health (Bug) — DONE, together with item 2

- Where: `OpenWorkouts/Views/StartView.swift:54`.
- What: `startWorkout()` creates `Workout(startedAt: .now)`. `WorkoutView` then shows **End workout** directly, so `WorkoutActions.start` and `tracker.start` never run. On **End workout**, `HealthKitTracker.end` finds no session and returns `nil`. No workout is ever saved to Health/Fitness, which breaks hard rule 2.
- Side effect: the **Start workout** button and `discardIfEmptyDraft` are dead code today.
- Fix: `let workout = Workout()` in `startWorkout()`. Remove the "Known issue" sections in `documentation/views/start.md`, `views/workout.md`, `features/workouts.md`.
- Test: UI test "New workout → Start workout button visible → tap → End workout visible". Must land together with item 2.

### 2. Draft workout deleted on tab switch, then used again (Bug) — DONE

- Where: `OpenWorkouts/Views/WorkoutView.swift:92` (`.onDisappear { discardIfEmptyDraft }`).
- What: `onDisappear` also fires when the user switches tabs. An empty draft is deleted while `StartView.activeWorkout` still holds it and `WorkoutView` is still on the stack. Returning to the Start tab renders a deleted model: crash or undefined state.
- Fix (smallest): run the cleanup when `activeWorkout` goes back to `nil` in `StartView` (`.onChange(of: activeWorkout)` with the old value), not in `WorkoutView.onDisappear`.
- Test: unit test stays on `WorkoutActions.discardIfEmptyDraft`; add a UI test: New workout → switch tab → back → still on Workout view.

### 3. Started workout abandoned with the back button: Health session never ends (Bug) — DONE (HK session recovery still a shortcut)

- Where: `WorkoutView` (no guard on back navigation), `HealthKitTracker`.
- What: after **Start workout**, the back button pops the view. The workout stays with `startedAt` and no `endedAt`: invisible everywhere (Start, History, Statistics filter on finished), never resumable, and the `HKWorkoutSession` keeps running until the app dies. Same if the app is killed mid-workout.
- Fix (smallest): hide the back button while a workout is running (`.navigationBarBackButtonHidden(workout.startedAt != nil)`), so **End workout** is the only way out. On launch, `StartView` reopens the newest unfinished started workout (query `endedAt == nil && startedAt != nil`).
- `shortcut:` a killed app loses the live HK session; upgrade with `HKHealthStore.recoverActiveWorkoutSession` if users report missing Fitness entries.
- Test: UI test that the back button is gone after Start; unit test for the "find unfinished workout" query.

### 4. Duplicate exercises and profiles across iCloud devices (Bug)

- Where: `OpenWorkouts/Logic/Seed.swift:17`, `OpenWorkouts/Models/Profile.swift:13`.
- What: both run before CloudKit has synced. A second device (or a reinstall) sees an empty store, seeds 72 exercises and creates a new `Profile`. After sync the user has 144 exercises and two profiles. `Profile.current` returns `.first`, which has no defined order, so Statistics/History may use one profile while Settings edits the other.
- Fix:
  - Exercises: after sync, merge seeded duplicates by name (`isSeeded == true`, same `name`): keep the one with entries, re-point `WorkoutEntry.exercise`, delete the rest. Run at launch and on `NSPersistentStoreRemoteChange`. This also gives `isSeeded` its first real use (it is stored but never read today).
  - Profile: `Profile.current` sorts deterministically (add `createdAt` with a default) keeps the oldest and deletes the others.
- Test: unit test inserting two seeded copies + entries, run dedupe, expect one exercise and entries re-pointed. Same for two profiles.

---

## P2: Bugs that silently change past data

### 5. Deleting or editing an exercise rewrites history (Bug)

- Where: `ExerciseListView.swift:29` (delete), `ExerciseEditView.swift:85` (save), `WorkoutStats.totalWeight`.
- What: stats are derived from the *current* exercise config. Deleting an exercise nullifies `WorkoutEntry.exercise`: history shows "Exercise", bodyweight sets drop to 0 kg, per-side sets stop doubling. Editing `trackedFields`/`perSide` on a used exercise changes every past total.
- Fix (smallest): block delete of exercises that have entries (`exercise.entries?.isEmpty == false` → alert "Used in N workouts"). Accept the edit case with a `shortcut:` comment and a doc line; upgrade by snapshotting `perSide`/bodyweight flag on `WorkoutEntry` if users complain.
- Test: unit test for the "can delete" check.

### 6. Historical totals follow today's bodyweight (Debt)

- Where: every caller of `WorkoutStats.totalWeight` / `estimatedKcal`.
- What: bodyweight is not stored on the workout, so changing `Profile.weightKg` changes all past totals and kcal.
- Fix: add `bodyweightKg: Double?` to `Workout`, set in `WorkoutActions.end` from the profile; stats use `workout.bodyweightKg ?? profile.weightKg`. Small, and removes the need to pass bodyweight around for finished workouts.
- Test: extend `WorkoutStatsTests`.

### 7. Reseed after the user deletes all exercises (Bug, minor)

- Where: `Seed.seedIfNeeded` (`fetchCount == 0`).
- What: a user who deletes every exercise gets all 72 back on next launch.
- Fix: store a `seeded` flag in `UserDefaults` (or `NSUbiquitousKeyValueStore` so it survives across devices, which also helps item 4). Fold into item 4.

---

## P3: Inconsistency and technical debt

### 8. Three different ways to read bodyweight (Debt + small Bug)

- `StartView`/`HistoryView`: `@State bodyweightKg = 75` loaded once in `.task`. Stale until the view re-appears.
- `PostWorkoutView`: `@Query profiles`, fallback `Profile().weightKg` (instantiates a `@Model` just to read a default).
- `StatisticsView:12` and `ProfileView:8`: `Profile.current(in:)` inside `body`, which can insert a model during view evaluation.
- The default `75` is written in three places.
- Fix: one pattern everywhere: `@Query private var profiles: [Profile]` + `profiles.first?.weightKg ?? Profile.defaultWeightKg`. Create the profile once at launch next to `Seed.seedIfNeeded`, never in `body`. Deletes the `@State` + `.task` pairs.

### 9. Test-only seeding code in a production view (Debt)

- Where: `StartView.swift:39-48` (`-seedSampleWorkouts`).
- Fix: move into `OpenWorkoutsApp.init` next to the `-uiTesting` branch, so `StartView.task` only loads data. Same behaviour, view stays clean.

### 10. Container failure crashes on launch (Debt)

- Where: `OpenWorkoutsApp.swift:23` (`fatalError`).
- What: any future model change that CloudKit rejects (non-optional property, unique attribute) bricks the app at launch with no message.
- Fix: no code change now. Add a schema test that builds a `ModelContainer` with `cloudKitDatabase: .automatic`-equivalent validation, or at minimum a checklist in `documentation/features/data-storage.md` for model changes. Upgrade to `VersionedSchema` + `SchemaMigrationPlan` before the first schema change that ships.

### 11. Unused HealthKit read permission and wrong usage text (Debt)

- Where: `HealthKitTracker.swift:24` reads `.bodyMass`, never used. `NSHealthShareUsageDescription` says the app "reads your workouts", it does not.
- Fix: drop `.bodyMass` from the read set (or use it to prefill `Profile.weightKg`, only if wanted). Change the text to "reads active energy". App Review rejects unused permissions.

### 12. Double tap on Start/End workout (Bug, minor)

- Where: `WorkoutView.swift:106`, `:113`.
- What: each tap spawns a `Task`. Two quick taps on **Start workout** call `tracker.start` twice; the first `HKWorkoutSession` is overwritten and never ended.
- Fix: `guard session == nil` at the top of `HealthKitTracker.start`, and set `workout.startedAt` before the `await` (already the case) so the button disappears on the first tap.

### 13. Deleting a workout does not delete it from Health (Debt, document only)

- Where: `HistoryView.swift:21`.
- Fix: document as a known limit in `views/history.md` with a `shortcut:` comment. Upgrade: store the `HKWorkout` UUID on `Workout` and delete it too.

### 14. Ratings: "not rated" equals 5 (Debt, minor)

- Where: `Workout.feltRating/sleepRating/caloriesEatenRating = 5`.
- What: a user who skips the sliders records 5/10. Fine as long as no stat reads ratings. Note it in `views/post-workout.md`; change to `Int?` only when ratings feed statistics.

### 15. No input validation on profile numbers (Bug, minor)

- Where: `ProfileView.swift:26-32`.
- What: weight 0 or negative is accepted, giving 0 or negative kcal and bodyweight loads (`max(0, …)` hides part of it).
- Fix: clamp on submit (`weightKg = max(20, min(400, weightKg))`) or use a `Stepper` like age.

---

## P4: Simplifications (less code, same behaviour)

| # | Where | Change |
|---|---|---|
| 16 | `WorkoutStats.finished` | `compactMap` to tuples + sort + map → `all.filter { ($0.endedAt ?? .distantPast) >= lower && $0.endedAt != nil }.sorted { $0.endedAt! > $1.endedAt! }`, or move the filter into `@Query` with a `#Predicate` and drop the re-sort (the `@Query` is already sorted by `endedAt`). |
| 17 | `ExerciseListView` vs `ExercisePicker` | Search uses `localizedCaseInsensitiveContains` in one and `localizedStandardContains` in the other. Use `localizedStandardContains` in both (diacritic-insensitive). |
| 18 | `HealthService.swift` | File holds `WorkoutTracking` + `NoopTracker`, no "service". Rename to `WorkoutTracking.swift`; update `health-fitness.md`. |
| 19 | `WorkoutActions` | Logic lives in `Views/WorkoutView.swift`. Move to `Logic/WorkoutActions.swift` (matches the repo layout in AGENTS.md). No code change. |
| 20 | `Since: Codable` | Never encoded. Drop `Codable`. |
| 21 | `SetRow.numberField` | Two overloads differ only in keyboard type. Keep: merging needs a generic over `BinaryInteger`/`FloatingPoint` formats, which is more code. Listed so nobody "fixes" it. |

---

## Order of work

1. Items 1 + 2 + 3 together (one PR: workout lifecycle). Highest value, touches `StartView`, `WorkoutView`, `HealthKitTracker`.
2. Item 4 + 7 (sync dedupe, seed flag).
3. Items 5, 6, 8 (stats correctness, one bodyweight pattern).
4. Items 9, 11, 12, 15 (small, independent).
5. P4 table and doc-only items (10, 13, 14) as cleanup.

Not checked: behaviour on a real device with HealthKit and CloudKit (simulator tests skip both), current coverage numbers, and the UI test files in detail.
