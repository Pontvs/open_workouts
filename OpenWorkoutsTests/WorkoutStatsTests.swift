import Foundation
import SwiftData
import Testing
@testable import OpenWorkouts

@MainActor
struct WorkoutStatsTests {
    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    /// Builds a workout with one entry per (exercise, reps/weight pairs) tuple.
    private func workout(
        _ context: ModelContext,
        started: Date? = nil,
        ended: Date? = nil,
        entries: [(Exercise?, [WorkoutSet])] = []
    ) -> Workout {
        let w = Workout(startedAt: started)
        w.endedAt = ended
        context.insert(w)
        for (index, (exercise, sets)) in entries.enumerated() {
            let entry = WorkoutEntry(order: index, workout: w, exercise: exercise)
            context.insert(entry)
            for (setIndex, set) in sets.enumerated() {
                set.order = setIndex
                set.entry = entry
                context.insert(set)
            }
        }
        return w
    }

    private func set(reps: Int? = nil, weight: Double? = nil, extra: Double? = nil, assist: Double? = nil) -> WorkoutSet {
        let s = WorkoutSet()
        s.reps = reps
        s.weightKg = weight
        s.extraKg = extra
        s.assistKg = assist
        return s
    }

    private func exercise(_ category: ExerciseCategory = .strength, fields: Set<TrackedField> = [.reps, .weight], mode: BodyweightMode = .none, perSide: Bool = false) -> Exercise {
        Exercise(category: category, trackedFields: fields, bodyweightMode: mode, perSide: perSide)
    }

    // MARK: duration

    @Test func durationIsZeroWhenNotStarted() throws {
        let context = try makeContext()
        let w = workout(context, ended: date(2026, 1, 1))
        #expect(WorkoutStats.duration(w) == 0)
    }

    @Test func durationUsesNowWhenUnfinished() throws {
        let context = try makeContext()
        let start = date(2026, 1, 1, hour: 10)
        let w = workout(context, started: start)
        #expect(WorkoutStats.duration(w, now: start.addingTimeInterval(90)) == 90)
    }

    @Test func durationUsesEndedAtWhenFinished() throws {
        let context = try makeContext()
        let start = date(2026, 1, 1, hour: 10)
        let w = workout(context, started: start, ended: start.addingTimeInterval(3600))
        #expect(WorkoutStats.duration(w, now: start.addingTimeInterval(9999)) == 3600)
    }

    // MARK: load

    @Test func loadUsesWeightWhenNotBodyweight() {
        let s = set(weight: 80)
        #expect(WorkoutStats.load(s, exercise: exercise(), bodyweightKg: 75) == 80)
    }

    @Test func loadIsZeroWithoutWeightOrExercise() {
        #expect(WorkoutStats.load(set(), exercise: exercise(), bodyweightKg: 75) == 0)
        #expect(WorkoutStats.load(set(weight: 20), exercise: nil, bodyweightKg: 75) == 20)
        #expect(WorkoutStats.load(set(extra: 10), exercise: nil, bodyweightKg: 75) == 0)
    }

    @Test func loadAddsExtraWeightToBodyweight() {
        let ex = exercise(fields: [.reps, .bodyweight], mode: .extra)
        #expect(WorkoutStats.load(set(extra: 10), exercise: ex, bodyweightKg: 75) == 85)
        #expect(WorkoutStats.load(set(), exercise: ex, bodyweightKg: 75) == 75)
    }

    @Test func loadSubtractsAssistanceFromBodyweight() {
        let ex = exercise(fields: [.reps, .bodyweight], mode: .assisted)
        #expect(WorkoutStats.load(set(assist: 20), exercise: ex, bodyweightKg: 75) == 55)
    }

    @Test func loadFloorsBodyweightAtZero() {
        let ex = exercise(fields: [.reps, .bodyweight], mode: .assisted)
        #expect(WorkoutStats.load(set(assist: 100), exercise: ex, bodyweightKg: 75) == 0)
    }

    @Test func loadIgnoresWeightForBodyweightExercise() {
        let ex = exercise(fields: [.reps, .bodyweight], mode: .extra)
        #expect(WorkoutStats.load(set(weight: 999), exercise: ex, bodyweightKg: 70) == 70)
    }

    // MARK: totalWeight

    @Test func totalWeightSumsRepsTimesLoad() throws {
        let context = try makeContext()
        let w = workout(context, entries: [
            (exercise(), [set(reps: 5, weight: 100), set(reps: 3, weight: 110)]),
            (exercise(), [set(reps: 10, weight: 20)]),
        ])
        #expect(WorkoutStats.totalWeight(w, bodyweightKg: 75) == 5 * 100 + 3 * 110 + 10 * 20)
    }

    @Test func totalWeightDoublesPerSideExercises() throws {
        let context = try makeContext()
        let w = workout(context, entries: [(exercise(perSide: true), [set(reps: 10, weight: 12)])])
        #expect(WorkoutStats.totalWeight(w, bodyweightKg: 75) == 240)
    }

    @Test func totalWeightTreatsNilRepsAsZero() throws {
        let context = try makeContext()
        let w = workout(context, entries: [(exercise(), [set(weight: 100), set(reps: 4, weight: 50)])])
        #expect(WorkoutStats.totalWeight(w, bodyweightKg: 75) == 200)
    }

    @Test func totalWeightUsesBodyweightLoad() throws {
        let context = try makeContext()
        let ex = exercise(fields: [.reps, .bodyweight], mode: .extra)
        let w = workout(context, entries: [(ex, [set(reps: 10, extra: 5)])])
        #expect(WorkoutStats.totalWeight(w, bodyweightKg: 75) == 800)
    }

    @Test func totalWeightOfEmptyWorkoutIsZero() throws {
        let context = try makeContext()
        #expect(WorkoutStats.totalWeight(workout(context), bodyweightKg: 75) == 0)
    }

    // MARK: estimatedKcal

    @Test func estimatedKcalPrefersActiveEnergy() throws {
        let context = try makeContext()
        let start = date(2026, 1, 1, hour: 10)
        let w = workout(context, started: start, ended: start.addingTimeInterval(3600), entries: [(exercise(), [])])
        w.activeEnergyKcal = 432
        #expect(WorkoutStats.estimatedKcal(w, bodyweightKg: 75) == 432)
    }

    @Test func estimatedKcalWithNoEntriesUsesDefaultMet() throws {
        let context = try makeContext()
        let start = date(2026, 1, 1, hour: 10)
        let w = workout(context, started: start, ended: start.addingTimeInterval(3600))
        // MET 5 * 80 kg * 1 h
        #expect(WorkoutStats.estimatedKcal(w, bodyweightKg: 80) == 400)
    }

    @Test func estimatedKcalAveragesMetAcrossEntries() throws {
        let context = try makeContext()
        let start = date(2026, 1, 1, hour: 10)
        let w = workout(context, started: start, ended: start.addingTimeInterval(1800), entries: [
            (exercise(.strength), []),  // 6
            (exercise(.cardio), []),    // 8
            (exercise(.mobility), []),  // 3
        ])
        // average MET 17/3, half an hour, 60 kg
        #expect(abs(WorkoutStats.estimatedKcal(w, bodyweightKg: 60) - (17.0 / 3.0) * 60 * 0.5) < 1e-9)
    }

    @Test func estimatedKcalMetForSingleCardioEntry() throws {
        let context = try makeContext()
        let start = date(2026, 1, 1, hour: 10)
        let w = workout(context, started: start, ended: start.addingTimeInterval(3600), entries: [(exercise(.cardio), [])])
        #expect(WorkoutStats.estimatedKcal(w, bodyweightKg: 70) == 560)
    }

    @Test func estimatedKcalUsesNowForUnfinishedWorkout() throws {
        let context = try makeContext()
        let start = date(2026, 1, 1, hour: 10)
        let w = workout(context, started: start)
        #expect(WorkoutStats.estimatedKcal(w, bodyweightKg: 75, now: start.addingTimeInterval(1800)) == 5 * 75 * 0.5)
    }

    @Test func estimatedKcalIsZeroBeforeStart() throws {
        let context = try makeContext()
        #expect(WorkoutStats.estimatedKcal(workout(context), bodyweightKg: 75) == 0)
    }

    // MARK: finished

    @Test func finishedFiltersUnfinishedAndSortsNewestFirst() throws {
        let context = try makeContext()
        let now = date(2026, 6, 15)
        let old = workout(context, ended: date(2026, 5, 1))
        let newest = workout(context, ended: date(2026, 6, 10))
        let middle = workout(context, ended: date(2026, 5, 20))
        let unfinished = workout(context, started: date(2026, 6, 12))

        let result = WorkoutStats.finished([old, unfinished, newest, middle], since: .allTime, now: now)
        #expect(result.map { ObjectIdentifier($0) } == [newest, middle, old].map { ObjectIdentifier($0) })
    }

    @Test func finishedAppliesLowerBound() throws {
        let context = try makeContext()
        let now = date(2026, 6, 15)
        let inside = workout(context, ended: date(2026, 4, 1))
        let outside = workout(context, ended: date(2026, 1, 1))

        let threeMonths = WorkoutStats.finished([inside, outside], since: .threeMonths, now: now)
        #expect(threeMonths.map { ObjectIdentifier($0) } == [ObjectIdentifier(inside)])

        let oneYear = WorkoutStats.finished([inside, outside], since: .oneYear, now: now)
        #expect(oneYear.count == 2)
    }

    @Test func finishedIncludesWorkoutEndedExactlyAtBoundary() throws {
        let context = try makeContext()
        let now = date(2026, 6, 15)
        let boundary = try #require(Since.threeMonths.startDate(from: now))
        let w = workout(context, ended: boundary)
        #expect(WorkoutStats.finished([w], since: .threeMonths, now: now).count == 1)
    }

    @Test func finishedIsEmptyForEmptyInput() {
        #expect(WorkoutStats.finished([], since: .allTime).isEmpty)
    }

    // MARK: monthly

    @Test func monthlyGroupsByMonthAndSortsAscending() throws {
        let context = try makeContext()
        let jan = workout(context, ended: date(2026, 1, 20), entries: [(exercise(), [set(reps: 2, weight: 100)])])
        let janAgain = workout(context, ended: date(2026, 1, 2), entries: [(exercise(), [set(reps: 1, weight: 50)])])
        let dec = workout(context, ended: date(2025, 12, 31), entries: [(exercise(), [set(reps: 1, weight: 10)])])

        let buckets = WorkoutStats.monthly([jan, janAgain, dec], bodyweightKg: 75)
        #expect(buckets.count == 2)
        #expect(buckets[0].month == date(2025, 12, 1, hour: 0))
        #expect(buckets[0].count == 1)
        #expect(buckets[0].weightKg == 10)
        #expect(buckets[1].month == date(2026, 1, 1, hour: 0))
        #expect(buckets[1].count == 2)
        #expect(buckets[1].weightKg == 250)
        #expect(buckets[1].id == buckets[1].month)
    }

    @Test func monthlySkipsUnfinishedWorkouts() throws {
        let context = try makeContext()
        let unfinished = workout(context, started: date(2026, 3, 1))
        #expect(WorkoutStats.monthly([unfinished], bodyweightKg: 75).isEmpty)
    }

    @Test func monthlyEmptyInputGivesNoBuckets() {
        #expect(WorkoutStats.monthly([], bodyweightKg: 75).isEmpty)
    }
}
