import HealthKit
import Testing
@testable import OpenWorkouts

// Simulator has no HealthKit authorization, so these only check that calls degrade
// gracefully (log and return) instead of throwing or trapping.
@MainActor
struct HealthKitTrackerTests {
    @Test func configurationIsIndoorStrengthTraining() {
        let configuration = HealthKitTracker.configuration()
        #expect(configuration.activityType == .traditionalStrengthTraining)
        #expect(configuration.locationType == .indoor)
    }

    @Test func endWithoutStartReturnsNil() async {
        #expect(await HealthKitTracker().end(at: .now) == nil)
    }

    @Test func requestAuthorizationDoesNotThrow() async {
        await HealthKitTracker().requestAuthorization()
    }

    @Test func startThenEndDoesNotCrash() async {
        let tracker = HealthKitTracker()
        await tracker.start(at: .now)
        _ = await tracker.end(at: .now)
        // State is cleared after end, so a second end is a no-op.
        #expect(await tracker.end(at: .now) == nil)
    }
}
