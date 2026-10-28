import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var workouts: [Workout]
    @State private var since: Since = .oneYear

    var body: some View {
        let finished = WorkoutStats.finished(workouts, since: since, now: .now)
        let buckets = WorkoutStats.monthly(finished, bodyweightKg: Profile.current(in: modelContext).weightKg)
        let totalCount = buckets.reduce(0) { $0 + $1.count }
        let totalKg = buckets.reduce(0) { $0 + $1.weightKg }

        List {
            Picker("Since", selection: $since) {
                ForEach(Since.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("sincePicker")

            if finished.isEmpty {
                ContentUnavailableView(
                    "No workouts yet",
                    systemImage: "chart.bar",
                    description: Text("Finished workouts in this period show up here.")
                )
                .listRowBackground(Color.clear)
            } else {
                Section {
                    Chart(buckets, id: \.month) { bucket in
                        BarMark(x: .value("Month", bucket.month, unit: .month), y: .value("Workouts", bucket.count))
                    }
                    .frame(height: 200)
                } header: {
                    header("Workouts", "\(totalCount) workouts")
                }

                Section {
                    Chart(buckets, id: \.month) { bucket in
                        BarMark(x: .value("Month", bucket.month, unit: .month), y: .value("kg", bucket.weightKg))
                    }
                    .frame(height: 200)
                } header: {
                    header("Total weight lifted", "\(totalKg.formatted(.number.precision(.fractionLength(0)))) kg")
                }
            }
        }
        .navigationTitle("Statistics")
    }

    private func header(_ title: String, _ total: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(total).foregroundStyle(.secondary)
        }
    }
}
