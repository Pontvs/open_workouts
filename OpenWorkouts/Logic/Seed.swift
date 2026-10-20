import Foundation
import SwiftData

struct SeedExercise: Codable {
    let name: String
    let category: ExerciseCategory
    let trackedFields: [TrackedField]
    let bodyweightMode: BodyweightMode
    let primaryMuscles: [MuscleGroup]
    let secondaryMuscles: [MuscleGroup]
    let perSide: Bool
    let equipment: Equipment
}

enum Seed {
    static func seedIfNeeded(_ context: ModelContext) throws {
        guard try context.fetchCount(FetchDescriptor<Exercise>()) == 0 else { return }
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        for seed in try load(from: Data(contentsOf: url)) {
            context.insert(Exercise(
                name: seed.name,
                category: seed.category,
                trackedFields: Set(seed.trackedFields),
                bodyweightMode: seed.bodyweightMode,
                primaryMuscles: seed.primaryMuscles,
                secondaryMuscles: seed.secondaryMuscles,
                perSide: seed.perSide,
                equipment: seed.equipment,
                isSeeded: true
            ))
        }
        try context.save()
    }

    static func load(from data: Data) throws -> [SeedExercise] {
        try JSONDecoder().decode([SeedExercise].self, from: data)
    }
}
