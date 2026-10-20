# Post-Workout

Code: `OpenWorkouts/Views/PostWorkoutView.swift`. Shown inside [Workout](workout.md) once the workout has ended. Back button hidden.

## Layout

- Title "Workout complete".
- **Duration** (h:mm:ss, `endedAt − startedAt`).
- **Est. kcal burned**: HealthKit active energy if returned, else the MET estimate ([calculations](../features/calculations.md)).
- **Total weight lifted** in kg.
- Three sliders, 1–10, step 1, default 5, with the current value shown:
  - How it felt → `feltRating`
  - Sleep last night → `sleepRating`
  - Calories eaten → `caloriesEatenRating`
- Footer **Back to start** dismisses back to [Start](start.md).

## Behaviour

Sliders write straight to the `Workout` (SwiftData autosaves). Bodyweight comes from the stored `Profile`, or the default 75 kg if none exists yet.

## Accessibility identifiers

`feltSlider`, `sleepSlider`, `caloriesSlider`, `doneButton`.

## Tests

No UI test yet; calculations are covered in `WorkoutStatsTests`.
