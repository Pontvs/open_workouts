import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var workouts: [Workout]
    @State private var since: Since = .oneYear

    var body: some View {
        let now = Date.now
        let finished = WorkoutStats.finished(workouts, since: since, now: now)
        // All time starts at the oldest finished workout (finished is newest first).
        let start = since.startDate(from: now) ?? finished.last?.endedAt ?? now
        let points = WorkoutStats.cumulative(finished, bodyweightKg: Profile.current(in: modelContext).weightKg, from: start, now: now)
        let totalCount = points.last?.count ?? 0
        let totalKg = points.last?.weightKg ?? 0

        List {
            Picker("Since", selection: $since) {
                ForEach(Since.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("sincePicker")

            if finished.isEmpty {
                ContentUnavailableView(
                    "No workouts yet",
                    systemImage: "chart.xyaxis.line",
                    description: Text("Finished workouts in this period show up here.")
                )
                .listRowBackground(Color.clear)
            } else {
                Section {
                    Chart(points, id: \.date) { point in
                        LineMark(x: .value("Date", point.date), y: .value("Workouts", point.count))
                    }
                    .chartXScale(domain: start...now)
                    .chartXAxis { xAxis }
                    .frame(height: 200)
                } header: {
                    header("Workouts", "\(totalCount) workouts")
                }

                Section {
                    Chart(points, id: \.date) { point in
                        LineMark(x: .value("Date", point.date), y: .value("kg", point.weightKg))
                    }
                    .chartXScale(domain: start...now)
                    .chartXAxis { xAxis }
                    .frame(height: 200)
                } header: {
                    header("Total weight lifted", "\(totalKg.formatted(.number.precision(.fractionLength(0)))) kg")
                }
            }
        }
        .navigationTitle("Statistics")
    }

    @AxisContentBuilder private var xAxis: some AxisContent {
        switch since {
        case .threeMonths:
            AxisMarks(values: .stride(by: .weekOfYear, count: 2)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        case .sixMonths: AxisMarks(values: .stride(by: .month, count: 1)) { _ in monthMark }
        case .oneYear: AxisMarks(values: .stride(by: .month, count: 2)) { _ in monthMark }
        case .threeYears: AxisMarks(values: .stride(by: .month, count: 6)) { _ in monthMark }
        case .allTime: AxisMarks()
        }
    }

    @AxisMarkBuilder private var monthMark: some AxisMark {
        AxisGridLine()
        AxisValueLabel(format: .dateTime.month(.abbreviated).year(.twoDigits))
    }

    private func header(_ title: String, _ total: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(total).foregroundStyle(.secondary)
        }
    }
}
