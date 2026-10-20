import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var search = ""

    var body: some View {
        let filtered = exercises.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }

        List {
            ForEach(ExerciseCategory.allCases) { category in
                let items = filtered.filter { $0.category == category }
                if !items.isEmpty {
                    Section(category.title) {
                        ForEach(items) { exercise in
                            NavigationLink {
                                ExerciseEditView(exercise: exercise)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                    Text(exercise.equipment.title)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets { modelContext.delete(items[index]) }
                        }
                    }
                }
            }
        }
        .searchable(text: $search)
        .navigationTitle("Exercises")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    ExerciseEditView(exercise: nil)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add exercise")
                .accessibilityIdentifier("addExerciseToolbarButton")
            }
        }
    }
}
