# Data Storage

## Store

SwiftData, configured in `OpenWorkouts/App/OpenWorkoutsApp.swift`. Models: `Exercise`, `Workout`, `WorkoutEntry`, `WorkoutSet`, `Profile`.

| Mode | Configuration | When |
|---|---|---|
| Device | `ModelConfiguration(cloudKitDatabase: .automatic)` | Normal launch |
| In-memory | `ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)` | `-uiTesting` launch argument, or running under XCTest (`XCTestConfigurationFilePath`) |

Device mode syncs through CloudKit to the user's private database in `iCloud.se.openworkouts.app`. The app has no other network destination.

## Seeding

`Seed.seedIfNeeded` runs after the container is created. It inserts the bundled exercises when the store has no `Exercise` rows. See [exercises.md](exercises.md).

## CloudKit model rules

- Every stored property has a default value or is optional.
- Relationships are optional.
- No `@Attribute(.unique)`.
- Enums are stored as raw strings; typed accessors are computed.
- Array values (`trackedFieldsRaw`, muscle raw arrays) are stored as `[String]`.

## Profile

`Profile` is a single object, fetched or created by `Profile.current(in:)`. Fields: `age` (30), `gender` (""), `weightKg` (75), `heightCm` (175), `goal` (""). Edited on [views/settings.md](../views/settings.md).

## Deletion

- Deleting a workout cascades to its entries and sets.
- Deleting an exercise nullifies `WorkoutEntry.exercise`, so history keeps its sets.

## Privacy

No servers, analytics, or third-party SDKs. Data stays on the device or in the user's iCloud.
