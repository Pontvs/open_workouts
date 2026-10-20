# Exercise Picker

Code: `OpenWorkouts/Views/ExercisePicker.swift`. Sheet opened from [Workout](workout.md).

## Layout

- Title "Add exercise", **Cancel** in the toolbar.
- All exercises sorted by name; row = name, then "Category · Equipment".
- Search field filters by name (`localizedStandardContains`: case- and diacritic-insensitive).

## Behaviour

Tapping a row calls `onPick(exercise)` and dismisses. The Workout view then adds the entry via `WorkoutActions.addEntry`. The list is the same catalogue edited in [Settings](settings.md).
