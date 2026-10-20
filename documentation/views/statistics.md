# Statistics

Code: `OpenWorkouts/Views/StatisticsView.swift`. Second tab ("Statistics").

## Layout

- **Since** menu picker: All time, 3 years, 1 year, 6 months, 3 months. Default **1 year**.
- Empty state when no finished workouts in the range.
- Chart 1 **Workouts**: bars per month, header shows the total ("12 workouts").
- Chart 2 **Total weight lifted**: kg per month, header shows the total kg.

## Behaviour

Data: `WorkoutStats.finished(_, since:)` then `WorkoutStats.monthly(_, bodyweightKg:)` with `Profile.weightKg`. Workouts are bucketed by the month they **ended** ([calculations](../features/calculations.md)).

## Accessibility identifiers

`sincePicker`.

## Tests

`OpenWorkoutsUITests/StatisticsSettingsUITests.swift`: empty state and changing the picker.
