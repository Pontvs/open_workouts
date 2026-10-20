# Exercises

An exercise is a reusable definition that workout entries point to. Model: `OpenWorkouts/Models/Exercise.swift`. Enums: `OpenWorkouts/Models/Enums.swift`.

## Fields

| Field | Type (stored) | Values | Notes |
|---|---|---|---|
| `name` | String | free text | |
| `category` | `categoryRaw` | `strength`, `cardio`, `mobility` | Default `strength`. |
| `trackedFields` | `trackedFieldsRaw: [String]` | `reps`, `weight`, `bodyweight`, `distance`, `height`, `time` | Set of fields. Default `[reps, weight]`. Only these fields are shown when logging sets. |
| `bodyweightMode` | `bodyweightModeRaw` | `none`, `extra`, `assisted` | Default `none`. Changes how load is calculated (see `calculations.md`). |
| `primaryMuscles` | `primaryMusclesRaw: [String]` | see Muscles | |
| `secondaryMuscles` | `secondaryMusclesRaw: [String]` | see Muscles | |
| `perSide` | Bool | | If true, the load counts twice in total weight (unilateral work). |
| `equipment` | `equipmentRaw` | see Equipment | Default `barbell`. |
| `isSeeded` | Bool | | `true` for entries from `exercises.json`. |
| `entries` | relationship | | Inverse of `WorkoutEntry.exercise`, delete rule nullify. |

### Muscles

`chest`, `back`, `shoulders`, `biceps`, `triceps`, `forearms`, `core`, `glutes`, `quadriceps`, `hamstrings`, `calves`, `fullBody` (UI title "Full body").

### Equipment

`barbell`, `dumbbell`, `machine`, `kettlebell`, `bodyWeight` (UI "Bodyweight"), `resistanceBand` (UI "Resistance band"), `cable`, `other`.

### Bodyweight modes

- `none`: bodyweight is not part of the load.
- `extra`: bodyweight plus added load (e.g. weighted pull-ups).
- `assisted`: bodyweight minus assistance (e.g. assisted pull-ups).

## Seeded list

`OpenWorkouts/Resources/exercises.json` holds 72 exercises: 56 strength, 11 mobility, 5 cardio. Seeding (`Seed.seedIfNeeded`) runs at app launch and inserts them only when the store has no `Exercise` rows. Seeded rows have `isSeeded = true`.

Seeded exercises can be edited in the same way as user-created ones (see `views/settings.md`).

shortcut: seeding runs only on an empty store, so later changes to `exercises.json` do not reach existing installs, upgrade: add a versioned migration when the catalogue must change for existing users.

## Views

- Create, edit, and remove exercises: [views/settings.md](../views/settings.md).
- Choose exercises while building a workout: [views/exercise-picker.md](../views/exercise-picker.md).
