# Workout

Code: `OpenWorkouts/Views/WorkoutView.swift` (`WorkoutView`, `SetRow`, and `WorkoutActions` holding the testable mutations). Pushed from [Start](start.md).

## Layout

- Title "Workout". Toolbar **+ Add exercise** opens the [Exercise picker](exercise-picker.md) as a sheet.
- One section per entry, header = exercise name (plus "per side" when `perSide`).
- Each set row shows number fields only for the exercise's tracked fields:

  | Tracked field | Field placeholder | Stored in |
  |---|---|---|
  | reps | Reps | `reps` |
  | weight | kg | `weightKg` |
  | bodyweight + mode `extra` | +kg | `extraKg` |
  | bodyweight + mode `assisted` | -kg | `assistKg` |
  | distance | m | `distanceM` |
  | height | cm | `heightCm` |
  | time | sec | `seconds` |

- **Add set** under each entry. Swipe to delete a set or a whole entry.
- Footer:
  - Not started: **Start workout**.
  - Started: running timer (h:mm:ss, ticks every second) and red **End workout**. The back button is hidden, so **End workout** is the only way out and the Health session always finishes.
- Once `endedAt` is set the view body switches to [Post-workout](post-workout.md) in place (no extra navigation).

## Behaviour (`WorkoutActions`)

- `addEntry`: appends an entry with the next `order` and one empty set.
- `addSet`: new set with next `order`, copying all values of the previous set.
- `start`: sets `startedAt = now`, calls `tracker.start(at:)` → Fitness Traditional Strength Training session ([Health](../features/health-fitness.md)).
- `end`: sets `endedAt = now`, stores `await tracker.end(at:)` in `activeEnergyKcal`.
- `running(in:)`: newest workout with `startedAt` set and no `endedAt`. [Start](start.md) uses it to reopen an unfinished workout.
- `discardIfEmptyDraft`: deletes the workout if it was never started and has no entries. Called by [Start](start.md) when the view is popped, not on disappear, so switching tabs keeps the draft.

## Accessibility identifiers

`addExerciseButton`, `startWorkoutButton`, `endWorkoutButton`; set fields `RepsField`, `kgField`, `+kgField`, `-kgField`, `mField`, `cmField`, `secField`.

## Tests

`OpenWorkoutsTests/WorkoutViewLogicTests.swift` covers every `WorkoutActions` function with `FakeTracker`. UI tests for Start → End are in `OpenWorkoutsUITests/StartHistoryUITests.swift`.
