import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.endedAt, order: .reverse) private var workouts: [Workout]
    @State private var bodyweightKg = 75.0

    var body: some View {
        let finished = WorkoutStats.finished(workouts, since: .allTime, now: .now)
        Group {
            if finished.isEmpty {
                ContentUnavailableView(
                    "No workouts yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Finished workouts will appear here.")
                )
            } else {
                List {
                    ForEach(finished) { WorkoutRow(workout: $0, bodyweightKg: bodyweightKg) }
                        .onDelete { offsets in
                            for index in offsets { modelContext.delete(finished[index]) }
                        }
                }
            }
        }
        .navigationTitle("History")
        .task { bodyweightKg = Profile.current(in: modelContext).weightKg }
    }
}
