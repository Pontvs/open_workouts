# Start

Code: `OpenWorkouts/Views/StartView.swift` (also defines `WorkoutRow`, reused by History). First tab ("Start").

## Layout

- Up to 5 most recent **finished** workouts, newest first (`WorkoutStats.finished(_, since: .allTime)`).
  Each row (`WorkoutRow`): end date and time, duration (h:mm), number of exercises, total kg lifted.
- Empty state "No workouts yet" when there are none.
- Toolbar **See all** → [History](history.md).
- Footer **New workout** (full width, prominent) → inserts a `Workout` and pushes [Workout](workout.md).

Rows are not tappable.

## Behaviour

- Total kg uses `Profile.weightKg` for bodyweight exercises (see [calculations](../features/calculations.md)).
- `-seedSampleWorkouts` launch argument (UI tests only): when the store has no workouts, inserts 6 finished one-hour workouts, one per day ending now.

## Accessibility identifiers

| Element | Identifier |
|---|---|
| See all | `seeAllButton` |
| New workout | `newWorkoutButton` |

## Known issue

`New workout` creates the workout with `startedAt = .now`, so the Workout view opens already started: the Start button is skipped and `tracker.start` (Apple Fitness) is never called. It should create `Workout()` instead.

## Tests

`OpenWorkoutsUITests/StartHistoryUITests.swift`: empty state, See all + back, New workout navigates, 5 rows shown with 6 seeded.
