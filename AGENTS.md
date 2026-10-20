# AGENTS.md

Instructions for AI agents and contributors working on OpenWorkouts.

## What the app is

OpenWorkouts is a personal workout logger for iPhone. Users create workouts, add exercises, log sets, end the workout, rate it, and review statistics. Workouts are mirrored to Apple Health / Fitness as Traditional Strength Training.

## Stack

- Platform: iOS 26.0 minimum (`deploymentTarget` in `project.yml`).
- Language: Swift 6.0, SwiftUI.
- Persistence: SwiftData, synced through CloudKit (private database).
- Charts: Swift Charts.
- Health: HealthKit (`HKWorkoutSession`).
- Project generation: xcodegen (`project.yml` is the source of truth; `OpenWorkouts.xcodeproj` is generated).
- Third-party dependencies: none. Do not add any.

## Hard rules

1. **Data stays on the device or in the user's iCloud.** SwiftData + CloudKit private database only. No servers, no analytics, no third-party SDKs.
2. **Health integration.** A workout start creates an `HKWorkoutSession` with `.traditionalStrengthTraining`; ending the workout finishes the session and saves it to Health/Fitness.
3. **Coverage ≥ 90% on the `OpenWorkouts` target.** Every change ships with tests.
4. **Documentation is part of the change.** Every feature and view is documented in `.documentation/`. Update the relevant doc in the same change as the code.
5. **Coding style: "ponytail".** Smallest complete change. No unrequested abstractions. Use `shortcut: <limit>, <when to upgrade>` comments for known limits.

## CloudKit model rules

- Every stored property has a default value or is optional.
- Relationships are optional.
- No `@Attribute(.unique)`.
- Enums are stored as raw strings (`xxxRaw` properties), with computed typed accessors.

## Commands

Generate the project after changing `project.yml`:

```sh
xcodegen generate
```

Build and test (simulator):

```sh
xcodebuild test -project OpenWorkouts.xcodeproj -scheme OpenWorkouts -destination 'platform=iOS Simulator,name=iPhone 17' -enableCodeCoverage YES -resultBundlePath build/tests.xcresult CODE_SIGNING_ALLOWED=NO
```

Coverage report:

```sh
xcrun xccov view --report --only-targets build/tests.xcresult
```

Signing (device builds only):

- Set `DEVELOPMENT_TEAM` in `project.yml` (currently empty).
- The iCloud container is `iCloud.se.openworkouts.app` (set in `project.yml` entitlements).

## Test launch arguments

- `-uiTesting`: in-memory SwiftData store (no CloudKit), seeded exercises, `NoopTracker` for Health.
- `-seedSampleWorkouts`: seeds sample workouts. Only applies if the flag is read in `StartView`; check the view before relying on it.

Unit tests (`OpenWorkoutsTests`, Swift Testing) use an in-memory container through `makeContext()` and a `FakeTracker` from `TestSupport.swift`. The in-memory check also triggers under XCTest (`XCTestConfigurationFilePath`).

## Multi-agent workflow

Larger work is split across parallel agents (Haiku model):

1. A coordinating agent scaffolds the shared contracts first: models, protocols (`WorkoutTracking`), and the `WorkoutStats` API. Contracts land before views are built on them.
2. Each agent owns a disjoint set of files plus the tests for those files.
3. The coordinating agent merges, runs the full suite with coverage, and fills coverage gaps.

Rules for agents:

- Use a separate simulator per agent and a separate derived data path: `-derivedDataPath build/dd-<name>`.
- Edit only the files you own. If a change is needed elsewhere, report it to the coordinator.
- Update `.documentation/` for any view or feature you change.

## Repo layout

```
project.yml                      xcodegen spec (targets, entitlements, Info.plist keys, scheme)
OpenWorkouts/
  App/                           @main app, container setup, RootView (tabs)
  Models/                        SwiftData @Model classes and enums
  Logic/                         Seed loader, calculations and statistics helpers
  Health/                        WorkoutTracking protocol, NoopTracker, HealthKit service
  Views/                         SwiftUI screens (one file per screen or component)
  Resources/exercises.json       Seed exercise catalogue (72 entries)
  Info.plist, OpenWorkouts.entitlements
OpenWorkoutsTests/               Unit tests (Swift Testing), TestSupport.swift helpers
OpenWorkoutsUITests/             UI tests (XCTest, launch with -uiTesting)
.documentation/                  Feature and view docs; index in README.md
```

Generated, do not edit by hand: `OpenWorkouts.xcodeproj/`. Build output: `build/` (git-ignored).
