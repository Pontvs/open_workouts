import Foundation
import SwiftData

@Model
final class Workout {
    var createdAt: Date = Date.now
    var startedAt: Date?
    var endedAt: Date?
    var feltRating: Int = 5
    var sleepRating: Int = 5
    var caloriesEatenRating: Int = 5
    var activeEnergyKcal: Double?  // from HealthKit when available
    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.workout) var entries: [WorkoutEntry]? = []

    var sortedEntries: [WorkoutEntry] { (entries ?? []).sorted { $0.order < $1.order } }
    var isFinished: Bool { endedAt != nil }

    init(startedAt: Date? = nil) {
        self.startedAt = startedAt
    }
}

@Model
final class WorkoutEntry {
    var order: Int = 0
    var workout: Workout?
    var exercise: Exercise?
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.entry) var sets: [WorkoutSet]? = []

    var sortedSets: [WorkoutSet] { (sets ?? []).sorted { $0.order < $1.order } }

    init(order: Int = 0, workout: Workout? = nil, exercise: Exercise? = nil) {
        self.order = order
        self.workout = workout
        self.exercise = exercise
    }
}

@Model
final class WorkoutSet {
    var order: Int = 0
    var entry: WorkoutEntry?
    var reps: Int?
    var weightKg: Double?
    var extraKg: Double?
    var assistKg: Double?
    var distanceM: Double?
    var heightCm: Double?
    var seconds: Double?

    init(order: Int = 0, entry: WorkoutEntry? = nil) {
        self.order = order
        self.entry = entry
    }
}
