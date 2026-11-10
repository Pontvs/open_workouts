# OpenWorkouts

A personal workout logger for iPhone. Create a workout, add exercises, log sets, end and rate the workout, and look back at your statistics. Finished workouts are saved to Apple Health / Fitness as Traditional Strength Training.

## Why

Most workout apps send your training data to their own servers. I wanted one that doesn't. OpenWorkouts keeps everything on your device and in your own iCloud (SwiftData synced through the CloudKit private database). It has no servers, no accounts, no analytics and no third-party SDKs.

## Requirements

- Xcode with the iOS 26 SDK (the app needs iOS 26.0 or later)
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Run

`project.yml` is the source of truth, so generate the Xcode project first (and again after any change to `project.yml`):

```sh
xcodegen generate
open OpenWorkouts.xcodeproj
```

Pick the `OpenWorkouts` scheme and a simulator, then press Run.

To run on a real device, set `DEVELOPMENT_TEAM` in `project.yml`, run `xcodegen generate` again, and make sure your team can use the iCloud container `iCloud.se.openworkouts.app`.

## Test

Run the unit and UI tests on a simulator, with coverage:

```sh
xcodebuild test -project OpenWorkouts.xcodeproj -scheme OpenWorkouts \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -enableCodeCoverage YES -resultBundlePath build/tests.xcresult \
  CODE_SIGNING_ALLOWED=NO
```

Show the coverage report (the target is ≥ 90% on `OpenWorkouts`):

```sh
xcrun xccov view --report --only-targets build/tests.xcresult
```

Delete `build/tests.xcresult` before running again, because `xcodebuild` won't overwrite an existing result bundle.

## More

- Feature and view docs: [`documentation/`](documentation/README.md)
- Contributor and agent rules: [`AGENTS.md`](AGENTS.md)
