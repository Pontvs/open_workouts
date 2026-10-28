# Start

Code: `OpenWorkouts/Views/StartView.swift` (also defines `WorkoutRow`, reused by History). First tab ("Start").

## Layout

- Up to 5 most recent **finished** workouts, newest first (`WorkoutStats.finished(_, since: .allTime)`).
  Each row (`WorkoutRow`): end date and time, duration (h:mm), number of exercises, total kg lifted.
- Empty state "No workouts yet" when there are none.
- Toolbar **See all** → [History](history.md).
- Footer **New workout** (full width, prominent) → inserts an unstarted `Workout` (draft) and pushes [Workout](workout.md). When the user navigates back, `WorkoutActions.discardIfEmptyDraft` runs on the popped workout (`onChange` of `activeWorkout`).

Rows are not tappable.

## Behaviour

- On appear, if no workout is pushed, reopens the newest started but unfinished workout (`WorkoutActions.running(in:)`), e.g. after the app was killed mid-workout. shortcut: the HealthKit session itself is not recovered, so that workout is not saved to Fitness.
- Total kg uses `Profile.weightKg` for bodyweight exercises (see [calculations](../features/calculations.md)).
- `-seedSampleWorkouts` launch argument (UI tests only): when the store has no workouts, inserts 6 finished one-hour workouts, one per day ending now.

## Accessibility identifiers

| Element | Identifier |
|---|---|
| See all | `seeAllButton` |
| New workout | `newWorkoutButton` |

## Tests

`OpenWorkoutsUITests/StartHistoryUITests.swift`: empty state, See all + back, New workout navigates, New workout opens unstarted then starts, draft survives a tab switch, back button hidden once started, 5 rows shown with 6 seeded.
