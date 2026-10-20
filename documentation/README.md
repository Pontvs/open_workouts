# OpenWorkouts Documentation

Index of the project docs. Keep these in sync with the code in the same change (see [AGENTS.md](../AGENTS.md)).

## Views

Screens. Tabs: Start, Statistics, Settings.

- [Start](views/start.md): recent workouts, create workout
- [History](views/history.md): all workouts
- [Workout](views/workout.md): add exercises and sets, start and end
- [Exercise picker](views/exercise-picker.md): search and add exercises
- [Post-workout](views/post-workout.md): summary and ratings
- [Statistics](views/statistics.md): workouts and total weight charts
- [Settings](views/settings.md): profile and exercise CRUD

## Features

- [Exercises](features/exercises.md): fields, muscles, equipment, seeded list
- [Workouts](features/workouts.md): lifecycle, ratings, draft cleanup
- [Calculations](features/calculations.md): total weight, kcal, statistics aggregation
- [Health and Fitness](features/health-fitness.md): `WorkoutTracking`, `HKWorkoutSession`
- [Data storage](features/data-storage.md): SwiftData, CloudKit, in-memory mode
- [Testing](features/testing.md): targets, commands, coverage, helpers

## Project

- [AGENTS.md](../AGENTS.md): rules, commands, multi-agent workflow, repo layout
