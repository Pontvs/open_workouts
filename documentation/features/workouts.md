# Workouts

A workout is one training session. Models: `OpenWorkouts/Models/Workout.swift` (`Workout`, `WorkoutEntry`, `WorkoutSet`).

## Structure

- `Workout`: `createdAt`, `startedAt?`, `endedAt?`, `feltRating`, `sleepRating`, `caloriesEatenRating`, `activeEnergyKcal?`, `entries`.
- `WorkoutEntry`: one `Exercise` in a workout, at position `order`. Owns `sets`.
- `WorkoutSet`: one set at position `order`. Fields are optional; only those the exercise tracks are filled:
  - `reps: Int?`
  - `weightKg: Double?`
  - `extraKg: Double?`, `assistKg: Double?` (bodyweight modes)
  - `distanceM: Double?`
  - `heightCm: Double?`
  - `seconds: Double?`
- Deleting a workout cascades to its entries and sets. Deleting an exercise nullifies the link on its entries.

## Lifecycle

1. **Draft**: `startedAt == nil`, `endedAt == nil`. Exercises and sets can be added.
2. **Started**: `startedAt` set by the Start button on the workout view. A timer runs. A Health session is started (see [health-fitness.md](health-fitness.md)).
3. **Ended**: `endedAt` set by the End button. The Health session is finished and saved. `activeEnergyKcal` is stored when HealthKit returns a value. The user then rates the workout on the post-workout view.

`isFinished` is `endedAt != nil`.

### Empty draft cleanup

When the Workout view disappears, a workout that was never started and has no entries is deleted (`WorkoutActions.discardIfEmptyDraft`).

Known issue: Start's **New workout** creates the workout already started, so the Draft state and this cleanup are currently skipped. See [views/start.md](../views/start.md).

## Ratings

Three integer ratings, 1 to 10, default 5:

- `feltRating`: how the workout felt.
- `sleepRating`: sleep the previous night.
- `caloriesEatenRating`: calories eaten.

Set on [views/post-workout.md](../views/post-workout.md).

## Ordering

`sortedEntries` and `sortedSets` sort by `order`.

## Views

- [views/start.md](../views/start.md): recent workouts and entry to create one
- [views/history.md](../views/history.md): all workouts
- [views/workout.md](../views/workout.md): draft and active workout
- [views/post-workout.md](../views/post-workout.md): summary and ratings
