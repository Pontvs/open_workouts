# Health and Fitness

Workouts are reported to Apple Health and appear in Fitness as Traditional Strength Training.

## Contract

Code: `OpenWorkouts/Health/HealthService.swift`.

```swift
@MainActor protocol WorkoutTracking: AnyObject {
    func requestAuthorization() async
    func start(at date: Date) async
    func end(at date: Date) async -> Double?   // active energy kcal if measured
}
```

- `NoopTracker`: does nothing, returns `nil`. The environment default, and what the app uses under `-uiTesting` / XCTest.
- `HealthKitTracker` (`OpenWorkouts/Health/HealthKitTracker.swift`): used on normal launches, chosen in `OpenWorkoutsApp` and injected with `.environment(\.tracker, …)`.

## HealthKitTracker

- `requestAuthorization()`: called once from `RootView`'s `.task` at launch. Share: workouts, active energy. Read: active energy, body mass. Skipped when Health data is unavailable.
- `start(at:)`: `HKWorkoutConfiguration` (`.traditionalStrengthTraining`, `.indoor`) → `HKWorkoutSession` + `HKLiveWorkoutBuilder` with `HKLiveWorkoutDataSource`, `startActivity`, `beginCollection`. This is what tells Apple Fitness a strength workout started. If the builder fails, the session is ended so Health doesn't keep tracking.
- `end(at:)`: ends the session, `endCollection`, `finishWorkout` (saves to Health, shows in Fitness), returns the summed active energy kcal, stored in `Workout.activeEnergyKcal`. Returns `nil` if no session is running or on error.
- Errors are logged with `os.Logger` (subsystem `se.openworkouts.app`, category `HealthKit`), never thrown to the UI.

Not verified: a real session in Fitness needs a signed device build; the simulator tests run without the HealthKit entitlement.

## Permissions and entitlements

- `project.yml` Info keys: `NSHealthShareUsageDescription` (reads workouts and active energy), `NSHealthUpdateUsageDescription` (saves workouts).
- Entitlement: `com.apple.developer.healthkit: true`.

## Testing

`OpenWorkoutsTests/HealthKitTrackerTests.swift` checks the configuration and that start/end/authorization fail gracefully without the entitlement. Views and logic depend on `WorkoutTracking`, so tests inject `FakeTracker` (`OpenWorkoutsTests/TestSupport.swift`). It records `startedAt`, `endedAt` and returns a configurable `energy`.
