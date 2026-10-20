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
  - Started: running timer (h:mm:ss, ticks every second) and red **End workout**.
- Once `endedAt` is set the view body switches to [Post-workout](post-workout.md) in place (no extra navigation).

## Behaviour (`WorkoutActions`)

- `addEntry`: appends an entry with the next `order` and one empty set.
- `addSet`: new set with next `order`, copying all values of the previous set.
- `start`: sets `startedAt = now`, calls `tracker.start(at:)` → Fitness Traditional Strength Training session ([Health](../features/health-fitness.md)).
- `end`: sets `endedAt = now`, stores `await tracker.end(at:)` in `activeEnergyKcal`.
- `discardIfEmptyDraft` (on disappear): deletes the workout if it was never started and has no entries.

See the known issue in [Start](start.md): workouts currently open already started.

## Accessibility identifiers

`addExerciseButton`, `startWorkoutButton`, `endWorkoutButton`; set fields `RepsField`, `kgField`, `+kgField`, `-kgField`, `mField`, `cmField`, `secField`.

## Tests

`OpenWorkoutsTests/WorkoutViewLogicTests.swift` covers every `WorkoutActions` function with `FakeTracker`. No UI test for this view yet.
