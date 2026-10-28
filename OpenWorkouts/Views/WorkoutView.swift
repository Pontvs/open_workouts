import SwiftUI
import SwiftData

@MainActor
enum WorkoutActions {
    static func addEntry(_ exercise: Exercise, to workout: Workout, context: ModelContext) {
        let entry = WorkoutEntry(order: (workout.sortedEntries.last?.order ?? 0) + 1, workout: workout, exercise: exercise)
        context.insert(entry)
        context.insert(WorkoutSet(order: 1, entry: entry))
    }

    /// Copies the previous set so repeating a set is one tap.
    static func addSet(to entry: WorkoutEntry, context: ModelContext) {
        let previous = entry.sortedSets.last
        let set = WorkoutSet(order: (previous?.order ?? 0) + 1, entry: entry)
        if let previous {
            set.reps = previous.reps
            set.weightKg = previous.weightKg
            set.extraKg = previous.extraKg
            set.assistKg = previous.assistKg
            set.distanceM = previous.distanceM
            set.heightCm = previous.heightCm
            set.seconds = previous.seconds
        }
        context.insert(set)
    }

    static func start(_ workout: Workout, tracker: any WorkoutTracking, now: Date = .now) async {
        workout.startedAt = now
        await tracker.start(at: now)
    }

    static func end(_ workout: Workout, tracker: any WorkoutTracking, now: Date = .now) async {
        workout.endedAt = now
        workout.activeEnergyKcal = await tracker.end(at: now)
    }

    /// Newest started, unfinished workout, e.g. after the app was killed mid-workout.
    static func running(in workouts: [Workout]) -> Workout? {
        workouts
            .filter { $0.startedAt != nil && !$0.isFinished }
            .max { ($0.startedAt ?? .distantPast) < ($1.startedAt ?? .distantPast) }
    }

    /// Drops drafts the user opened and abandoned so they don't pile up.
    static func discardIfEmptyDraft(_ workout: Workout, context: ModelContext) {
        guard workout.startedAt == nil, (workout.entries ?? []).isEmpty else { return }
        context.delete(workout)
    }
}

struct WorkoutView: View {
    let workout: Workout

    @Environment(\.modelContext) private var modelContext
    @Environment(\.tracker) private var tracker
    @State private var showingPicker = false

    var body: some View {
        if workout.isFinished {
            PostWorkoutView(workout: workout)
        } else {
            List {
                ForEach(workout.sortedEntries) { entry in
                    Section {
                        ForEach(entry.sortedSets) { set in
                            SetRow(set: set, exercise: entry.exercise)
                        }
                        .onDelete { offsets in
                            let sets = entry.sortedSets
                            for index in offsets { modelContext.delete(sets[index]) }
                        }
                        Button("Add set") { WorkoutActions.addSet(to: entry, context: modelContext) }
                    } header: {
                        VStack(alignment: .leading) {
                            Text(entry.exercise?.name ?? "Exercise")
                            if entry.exercise?.perSide == true {
                                Text("per side").font(.caption)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    let entries = workout.sortedEntries
                    for index in offsets { modelContext.delete(entries[index]) }
                }
            }
            .navigationTitle("Workout")
            // A running workout is left only through End, so the Health session always finishes.
            .navigationBarBackButtonHidden(workout.startedAt != nil)
            .toolbar {
                Button("Add exercise", systemImage: "plus") { showingPicker = true }
                    .accessibilityIdentifier("addExerciseButton")
            }
            .sheet(isPresented: $showingPicker) {
                ExercisePicker { exercise in
                    WorkoutActions.addEntry(exercise, to: workout, context: modelContext)
                }
            }
            .safeAreaInset(edge: .bottom) { footer }
        }
    }

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: 12) {
            if workout.startedAt != nil {
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    let elapsed = WorkoutStats.duration(workout, now: timeline.date)
                    Text(Duration.seconds(elapsed).formatted(.time(pattern: .hourMinuteSecond)))
                        .font(.title2.monospacedDigit())
                }
                Button("End workout") {
                    Task { await WorkoutActions.end(workout, tracker: tracker) }
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .accessibilityIdentifier("endWorkoutButton")
            } else {
                Button("Start workout") {
                    Task { await WorkoutActions.start(workout, tracker: tracker) }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("startWorkoutButton")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.bar)
    }
}

private struct SetRow: View {
    @Bindable var set: WorkoutSet
    let exercise: Exercise?

    var body: some View {
        let fields = exercise?.trackedFields ?? []
        let bodyweightMode = exercise?.bodyweightMode ?? .none
        HStack {
            if fields.contains(.reps) {
                numberField("Reps", value: $set.reps)
            }
            if fields.contains(.weight) {
                numberField("kg", value: $set.weightKg)
            }
            if fields.contains(.bodyweight), bodyweightMode != .none {
                numberField(bodyweightMode == .extra ? "+kg" : "-kg",
                            value: bodyweightMode == .extra ? $set.extraKg : $set.assistKg)
            }
            if fields.contains(.distance) {
                numberField("m", value: $set.distanceM)
            }
            if fields.contains(.height) {
                numberField("cm", value: $set.heightCm)
            }
            if fields.contains(.time) {
                numberField("sec", value: $set.seconds)
            }
        }
    }

    private func numberField(_ title: String, value: Binding<Int?>) -> some View {
        TextField(title, value: value, format: .number)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .accessibilityIdentifier("\(title)Field")
    }

    private func numberField(_ title: String, value: Binding<Double?>) -> some View {
        TextField(title, value: value, format: .number)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .accessibilityIdentifier("\(title)Field")
    }
}
