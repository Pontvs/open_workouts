import SwiftUI
import SwiftData

struct PostWorkoutView: View {
    let workout: Workout

    @Query private var profiles: [Profile]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let now = workout.endedAt ?? .now
        let bodyweightKg = profiles.first?.weightKg ?? Profile().weightKg
        Form {
            Section {
                LabeledContent("Duration") {
                    Text(Duration.seconds(WorkoutStats.duration(workout, now: now)).formatted(.time(pattern: .hourMinuteSecond)))
                        .monospacedDigit()
                }
                LabeledContent("Est. kcal burned") {
                    Text(WorkoutStats.estimatedKcal(workout, bodyweightKg: bodyweightKg, now: now).formatted(.number.precision(.fractionLength(0))))
                        .monospacedDigit()
                }
                LabeledContent("Total weight lifted") {
                    Text("\(WorkoutStats.totalWeight(workout, bodyweightKg: bodyweightKg).formatted(.number.precision(.fractionLength(0)))) kg")
                        .monospacedDigit()
                }
            }
            Section {
                ratingSlider("How it felt", \.feltRating, id: "feltSlider")
                ratingSlider("Sleep last night", \.sleepRating, id: "sleepSlider")
                ratingSlider("Calories eaten", \.caloriesEatenRating, id: "caloriesSlider")
            }
        }
        .navigationTitle("Workout complete")
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            Button("Back to start") { dismiss() }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("doneButton")
                .padding()
                .background(.bar)
        }
    }

    private func ratingSlider(_ title: String, _ keyPath: ReferenceWritableKeyPath<Workout, Int>, id: String) -> some View {
        let value = Binding(
            get: { Double(workout[keyPath: keyPath]) },
            set: { workout[keyPath: keyPath] = Int($0) }
        )
        return VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value.wrappedValue))").monospacedDigit()
            }
            Slider(value: value, in: 1...10, step: 1) { Text(title) }
                .accessibilityIdentifier(id)
        }
    }
}
