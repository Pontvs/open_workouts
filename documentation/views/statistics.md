# Statistics

Code: `OpenWorkouts/Views/StatisticsView.swift`. Second tab ("Statistics").

## Layout

- **Since** menu picker: All time, 3 years, 1 year, 6 months, 3 months. Default **1 year**.
- Empty state when no finished workouts in the range.
- Chart 1 **Workouts**: cumulative line of workouts, header shows the total ("12 workouts").
- Chart 2 **Total weight lifted**: cumulative line of kg, header shows the total kg.
- Both lines start at 0 on the first day of the **Since** range (All time: the oldest finished workout) and run to today.
- Date axis marks: 3 months every 2 weeks, 6 months every month, 1 year every 2 months, 3 years every 6 months, All time automatic.

## Behaviour

Data: `WorkoutStats.finished(_, since:)` then `WorkoutStats.cumulative(_, bodyweightKg:, from:)` with `Profile.weightKg`. Workouts are placed on the date they **ended** ([calculations](../features/calculations.md)).

## Accessibility identifiers

`sincePicker`.

## Tests

`OpenWorkoutsUITests/StatisticsSettingsUITests.swift`: empty state and changing the picker.
