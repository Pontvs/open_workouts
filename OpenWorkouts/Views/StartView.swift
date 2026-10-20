import SwiftUI
import SwiftData

struct StartView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.endedAt, order: .reverse) private var workouts: [Workout]
    @State private var activeWorkout: Workout?
    @State private var bodyweightKg = 75.0

    var body: some View {
        let recent = Array(WorkoutStats.finished(workouts, since: .allTime, now: .now).prefix(5))
        Group {
            if recent.isEmpty {
                ContentUnavailableView(
                    "No workouts yet",
                    systemImage: "figure.strengthtraining.traditional",
                    description: Text("Tap New workout to log your first one.")
                )
            } else {
                List(recent) { WorkoutRow(workout: $0, bodyweightKg: bodyweightKg) }
            }
        }
        .navigationTitle("Start")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("See all") { HistoryView() }
                    .accessibilityIdentifier("seeAllButton")
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("New workout", action: startWorkout)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding()
                .accessibilityIdentifier("newWorkoutButton")
        }
        .navigationDestination(item: $activeWorkout) { WorkoutView(workout: $0) }
        .task {
            // Debug hook for UI tests: seed only when empty so re-appearing doesn't duplicate rows.
            if ProcessInfo.processInfo.arguments.contains("-seedSampleWorkouts"), workouts.isEmpty {
                for days in 0..<6 {
                    let end = Date.now.addingTimeInterval(-Double(days) * 86_400)
                    let workout = Workout(startedAt: end.addingTimeInterval(-3_600))
                    workout.endedAt = end
                    modelContext.insert(workout)
                }
            }
            bodyweightKg = Profile.current(in: modelContext).weightKg
        }
    }

    private func startWorkout() {
        let workout = Workout(startedAt: .now)
        modelContext.insert(workout)
        activeWorkout = workout
    }
}

struct WorkoutRow: View {
    let workout: Workout
    let bodyweightKg: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.endedAt ?? .now, format: .dateTime.year().month().day().hour().minute())
                .font(.headline)
            HStack(spacing: 12) {
                Text(Duration.seconds(WorkoutStats.duration(workout, now: .now)).formatted(.time(pattern: .hourMinute)))
                Text("\(workout.sortedEntries.count) exercises")
                Text("\(WorkoutStats.totalWeight(workout, bodyweightKg: bodyweightKg).formatted(.number.precision(.fractionLength(0)))) kg")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
}
