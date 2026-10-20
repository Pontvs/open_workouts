import SwiftUI
import SwiftData

struct ExerciseEditView: View {
    let exercise: Exercise?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Local draft: edits only reach the model on Save.
    @State private var name: String
    @State private var category: ExerciseCategory
    @State private var trackedFields: Set<TrackedField>
    @State private var bodyweightMode: BodyweightMode
    @State private var primaryMuscles: Set<MuscleGroup>
    @State private var secondaryMuscles: Set<MuscleGroup>
    @State private var perSide: Bool
    @State private var equipment: Equipment

    init(exercise: Exercise?) {
        self.exercise = exercise
        _name = State(initialValue: exercise?.name ?? "")
        _category = State(initialValue: exercise?.category ?? .strength)
        _trackedFields = State(initialValue: exercise?.trackedFields ?? [.reps, .weight])
        _bodyweightMode = State(initialValue: exercise?.bodyweightMode ?? .none)
        _primaryMuscles = State(initialValue: Set(exercise?.primaryMuscles ?? []))
        _secondaryMuscles = State(initialValue: Set(exercise?.secondaryMuscles ?? []))
        _perSide = State(initialValue: exercise?.perSide ?? false)
        _equipment = State(initialValue: exercise?.equipment ?? .barbell)
    }

    var body: some View {
        Form {
            TextField("Name", text: $name)
                .accessibilityIdentifier("exerciseNameField")

            Picker("Category", selection: $category) {
                ForEach(ExerciseCategory.allCases) { Text($0.title).tag($0) }
            }

            Section("Tracked") {
                ForEach(TrackedField.allCases) { field in
                    Toggle(field.title, isOn: membership(field, in: $trackedFields))
                }
            }

            if trackedFields.contains(.bodyweight) {
                Picker("Bodyweight", selection: $bodyweightMode) {
                    ForEach(BodyweightMode.allCases) { Text(label(for: $0)).tag($0) }
                }
            }

            Section("Muscles") {
                DisclosureGroup("Primary") {
                    ForEach(MuscleGroup.allCases) { muscle in
                        Toggle(muscle.title, isOn: membership(muscle, in: $primaryMuscles))
                    }
                }
                DisclosureGroup("Secondary") {
                    ForEach(MuscleGroup.allCases) { muscle in
                        Toggle(muscle.title, isOn: membership(muscle, in: $secondaryMuscles))
                    }
                }
            }

            Toggle("Enter per side", isOn: $perSide)

            Picker("Equipment", selection: $equipment) {
                ForEach(Equipment.allCases) { Text($0.title).tag($0) }
            }
        }
        .navigationTitle(exercise == nil ? "New Exercise" : "Edit Exercise")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .accessibilityIdentifier("saveExerciseButton")
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() {
        let target = exercise ?? Exercise()
        if exercise == nil { modelContext.insert(target) }
        target.name = name.trimmingCharacters(in: .whitespaces)
        target.category = category
        target.trackedFields = trackedFields
        // Bodyweight mode only means something when bodyweight is tracked.
        target.bodyweightMode = trackedFields.contains(.bodyweight) ? bodyweightMode : .none
        target.primaryMuscles = MuscleGroup.allCases.filter(primaryMuscles.contains)
        target.secondaryMuscles = MuscleGroup.allCases.filter(secondaryMuscles.contains)
        target.perSide = perSide
        target.equipment = equipment
        dismiss()
    }

    private func membership<T: Hashable>(_ value: T, in set: Binding<Set<T>>) -> Binding<Bool> {
        Binding(
            get: { set.wrappedValue.contains(value) },
            set: { isOn in
                if isOn { set.wrappedValue.insert(value) } else { set.wrappedValue.remove(value) }
            }
        )
    }

    private func label(for mode: BodyweightMode) -> String {
        switch mode {
        case .none: "None"
        case .extra: "Extra weight"
        case .assisted: "Assisted weight"
        }
    }
}
