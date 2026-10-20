import Foundation
import SwiftData
@testable import OpenWorkouts

@MainActor
func makeContext() throws -> ModelContext {
    let container = try ModelContainer(
        for: Exercise.self, Workout.self, WorkoutEntry.self, WorkoutSet.self, Profile.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
    )
    return ModelContext(container)
}

@MainActor
final class FakeTracker: WorkoutTracking {
    var authorized = false
    var startedAt: Date?
    var endedAt: Date?
    var energy: Double?

    func requestAuthorization() async { authorized = true }
    func start(at date: Date) async { startedAt = date }
    func end(at date: Date) async -> Double? {
        endedAt = date
        return energy
    }
}
