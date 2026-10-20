import SwiftData

// Stored as raw strings: CloudKit-backed SwiftData can't store enums directly, and
// every property needs a default and no @Attribute(.unique).
@Model
final class Exercise {
    var name: String = ""
    var categoryRaw: String = ExerciseCategory.strength.rawValue
    var trackedFieldsRaw: [String] = [TrackedField.reps.rawValue, TrackedField.weight.rawValue]
    var bodyweightModeRaw: String = BodyweightMode.none.rawValue
    var primaryMusclesRaw: [String] = []
    var secondaryMusclesRaw: [String] = []
    var perSide: Bool = false
    var equipmentRaw: String = Equipment.barbell.rawValue
    var isSeeded: Bool = false
    @Relationship(deleteRule: .nullify, inverse: \WorkoutEntry.exercise) var entries: [WorkoutEntry]? = []

    var category: ExerciseCategory {
        get { ExerciseCategory(rawValue: categoryRaw) ?? .strength }
        set { categoryRaw = newValue.rawValue }
    }

    var trackedFields: Set<TrackedField> {
        get { Set(trackedFieldsRaw.compactMap(TrackedField.init(rawValue:))) }
        set { trackedFieldsRaw = newValue.map(\.rawValue).sorted() }
    }

    var bodyweightMode: BodyweightMode {
        get { BodyweightMode(rawValue: bodyweightModeRaw) ?? .none }
        set { bodyweightModeRaw = newValue.rawValue }
    }

    var primaryMuscles: [MuscleGroup] {
        get { primaryMusclesRaw.compactMap(MuscleGroup.init(rawValue:)) }
        set { primaryMusclesRaw = newValue.map(\.rawValue) }
    }

    var secondaryMuscles: [MuscleGroup] {
        get { secondaryMusclesRaw.compactMap(MuscleGroup.init(rawValue:)) }
        set { secondaryMusclesRaw = newValue.map(\.rawValue) }
    }

    var equipment: Equipment {
        get { Equipment(rawValue: equipmentRaw) ?? .other }
        set { equipmentRaw = newValue.rawValue }
    }

    init(
        name: String = "",
        category: ExerciseCategory = .strength,
        trackedFields: Set<TrackedField> = [.reps, .weight],
        bodyweightMode: BodyweightMode = .none,
        primaryMuscles: [MuscleGroup] = [],
        secondaryMuscles: [MuscleGroup] = [],
        perSide: Bool = false,
        equipment: Equipment = .barbell,
        isSeeded: Bool = false
    ) {
        self.name = name
        self.category = category
        self.trackedFields = trackedFields
        self.bodyweightMode = bodyweightMode
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.perSide = perSide
        self.equipment = equipment
        self.isSeeded = isSeeded
    }
}
