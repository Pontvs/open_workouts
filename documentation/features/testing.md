# Testing

## Targets

| Target | Framework | Purpose |
|---|---|---|
| `OpenWorkoutsTests` | Swift Testing | Models, logic, seeding, view models |
| `OpenWorkoutsUITests` | XCTest | UI flows, launched with `-uiTesting` |

## Requirements

- Coverage of the `OpenWorkouts` target must be at least 90%.
- Every change ships with tests.

## Running

```sh
xcodebuild test -project OpenWorkouts.xcodeproj -scheme OpenWorkouts -destination 'platform=iOS Simulator,name=iPhone 17' -enableCodeCoverage YES -resultBundlePath build/tests.xcresult CODE_SIGNING_ALLOWED=NO
xcrun xccov view --report --only-targets build/tests.xcresult
```

For parallel agents, add `-derivedDataPath build/dd-<name>` and use a separate simulator.

## Helpers

- `makeContext()` (`OpenWorkoutsTests/TestSupport.swift`): in-memory `ModelContext` with all app models and no CloudKit.
- `FakeTracker`: records start and end dates and returns a set energy value.

## Launch arguments

- `-uiTesting`: in-memory store, seeded exercises, `NoopTracker`.
- `-seedSampleWorkouts`: with `-uiTesting`, `StartView` inserts 6 finished workouts into an empty store.

## Suites

| File | Covers |
|---|---|
| `ModelTests` | enum accessors, ordering, `Profile.current`, `Since`, cascade delete |
| `SeedTests` | bundled JSON decodes, seeding runs once |
| `WorkoutStatsTests` | duration, load, total weight, kcal, since filter, monthly buckets |
| `WorkoutViewLogicTests` | `WorkoutActions` |
| `HealthKitTrackerTests` | configuration, graceful failure |
| `LaunchTests` | tabs exist |
| `StartHistoryUITests` | Start and History |
| `StatisticsSettingsUITests` | Statistics, Profile, exercise CRUD |

Gaps: no UI test for the Workout → Post-workout flow or the exercise picker. Coverage has not been measured against the 90% target yet.
