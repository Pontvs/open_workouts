# Calculations

Derived values shown in the post-workout view and in statistics. Only `activeEnergyKcal` is stored; everything else is computed.

## Total weight lifted

Load per set depends on the exercise's bodyweight mode:

Code: `WorkoutStats.load` in `OpenWorkouts/Logic/WorkoutStats.swift`.

| Exercise | Load per rep (kg) |
|---|---|
| does not track `bodyweight` | `weightKg ?? 0` |
| tracks `bodyweight` | `max(0, Profile.weightKg + (extraKg ?? 0) − (assistKg ?? 0))` |

Set total is `reps × load`, doubled when the exercise has `perSide = true`. Workout total is the sum over all sets of all entries. Sets without `reps` contribute nothing.

Bodyweight comes from the current `Profile.weightKg`, so changing the profile weight changes past totals.

## Estimated energy (kcal)

1. If HealthKit reported active energy for the workout (`Workout.activeEnergyKcal != nil`), use that value.
2. Otherwise: `kcal = MET × Profile.weightKg × hours`. MET is the average over the workout's entries of 6 (strength), 8 (cardio) or 3 (mobility); 5 when there are no entries. This ignores intensity (marked `shortcut:` in code).

## Duration

`(endedAt ?? now) − startedAt`; 0 before the workout is started. The live timer uses the same function.

## Statistics

- Only finished workouts (`isFinished`) are counted.
- **Since** filter: keeps finished workouts with `endedAt >= Since.startDate()`, newest first. `allTime` has no lower bound. The other ranges subtract 36, 12, 6 or 3 months from now, using `Calendar.current` (`OpenWorkouts/Models/Enums.swift`).
- Monthly buckets: workouts are grouped by calendar month of `endedAt`, oldest first; each bucket holds a count and total kg.
- Chart 1 shows the number of workouts per bucket. Chart 2 shows total weight lifted per bucket. See [views/statistics.md](../views/statistics.md).
