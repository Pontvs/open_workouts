# History

Code: `OpenWorkouts/Views/HistoryView.swift`. Pushed from [Start](start.md) via **See all**.

## Layout

- All finished workouts, newest first, using `WorkoutRow` from `StartView.swift`.
- Empty state "No workouts yet".

## Behaviour

- Swipe to delete removes the workout; entries and sets cascade.
- Rows are not tappable (there is no workout detail view).

## Tests

`OpenWorkoutsUITests/StartHistoryUITests.swift`: shows all 6 seeded workouts, swipe-delete removes one.
