import SwiftUI

@MainActor
protocol WorkoutTracking: AnyObject {
    func requestAuthorization() async
    func start(at date: Date) async
    /// Ends the session and saves the workout to Health/Fitness. Returns active energy kcal if HealthKit measured it.
    func end(at date: Date) async -> Double?
}

@MainActor
final class NoopTracker: WorkoutTracking {
    func requestAuthorization() async {}
    func start(at date: Date) async {}
    func end(at date: Date) async -> Double? { nil }
}

extension EnvironmentValues {
    @Entry var tracker: any WorkoutTracking = NoopTracker()
}
