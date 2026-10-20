# Settings

Code: `SettingsView.swift`, `ProfileView.swift`, `ExerciseListView.swift`, `ExerciseEditView.swift` in `OpenWorkouts/Views/`. Third tab ("Settings"), a list with **Profile** and **Exercises**.

## Profile (`ProfileView`)

Form bound directly to `Profile.current(in:)`; changes save as you type.

| Field | Control | Identifier |
|---|---|---|
| Age | Stepper 10–120 | `ageField` |
| Gender | Picker: Not set / Female / Male / Other / Prefer not to say | `genderPicker` |
| Weight (kg) | decimal field | `weightField` |
| Height (cm) | decimal field | `heightField` |
| Goal | multi-line text | `goalField` |

Weight feeds bodyweight loads and kcal estimates.

## Exercises (`ExerciseListView`)

- All exercises, searchable by name, grouped in sections by category; row = name + equipment.
- Tap → edit. Toolbar **+** (`addExerciseToolbarButton`) → new. Swipe to delete.
- Deleting an exercise keeps past workouts; their entries lose the link and show "Exercise".

## Exercise editor (`ExerciseEditView`)

Edits a local draft; nothing is written until **Save** (`saveExerciseButton`, disabled while the name is blank). **Cancel** discards.

Fields: name (`exerciseNameField`), category, tracked fields (one toggle each), bodyweight mode (None / Extra weight / Assisted weight, only shown when bodyweight is tracked and reset to None on save otherwise), primary and secondary muscles (toggle lists in disclosure groups), **Enter per side**, equipment. Seeded exercises are edited the same way. Field meanings: [exercises](../features/exercises.md).

## Tests

`OpenWorkoutsUITests/StatisticsSettingsUITests.swift`: profile values persist after leaving; add, edit and swipe-delete an exercise.
