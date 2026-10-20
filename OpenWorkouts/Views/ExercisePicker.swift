import SwiftUI
import SwiftData

struct ExercisePicker: View {
    let onPick: (Exercise) -> Void

    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var search = ""
    @Environment(\.dismiss) private var dismiss

    private var matches: [Exercise] {
        search.isEmpty ? exercises : exercises.filter { $0.name.localizedStandardContains(search) }
    }

    var body: some View {
        NavigationStack {
            List(matches) { exercise in
                Button {
                    onPick(exercise)
                    dismiss()
                } label: {
                    VStack(alignment: .leading) {
                        Text(exercise.name)
                        Text("\(exercise.category.title) · \(exercise.equipment.title)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $search)
            .navigationTitle("Add exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
