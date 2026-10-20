import Foundation
import SwiftData
import Testing
@testable import OpenWorkouts

@MainActor
struct WorkoutViewLogicTests {
    @Test func addEntryAppendsWithIncreasingOrderAndOneEmptySet() throws {
        let context = try makeContext()
        let workout = Workout()
        context.insert(workout)
        let bench = Exercise(name: "Bench")
        let squat = Exercise(name: "Squat")
        context.insert(bench)
        context.insert(squat)

        WorkoutActions.addEntry(bench, to: workout, context: context)
        WorkoutActions.addEntry(squat, to: workout, context: context)

        #expect(workout.sortedEntries.map(\.exercise?.name) == ["Bench", "Squat"])
        #expect(workout.sortedEntries.map(\.order) == [1, 2])
        #expect(workout.sortedEntries.allSatisfy { $0.sortedSets.count == 1 })
    }

    @Test func addSetCopiesPreviousSetValues() throws {
        let context = try makeContext()
        let workout = Workout()
        context.insert(workout)
        let entry = WorkoutEntry(order: 1, workout: workout, exercise: Exercise(name: "Bench"))
        context.insert(entry)
        let first = WorkoutSet(order: 1, entry: entry)
        first.reps = 8
        first.weightKg = 60
        context.insert(first)

        WorkoutActions.addSet(to: entry, context: context)

        let second = try #require(entry.sortedSets.last)
        #expect(second.order == 2)
        #expect(second.reps == 8)
        #expect(second.weightKg == 60)
    }

    @Test func startSetsStartedAtAndCallsTracker() async throws {
        let workout = Workout()
        let tracker = FakeTracker()
        let now = Date(timeIntervalSince1970: 1_000)

        await WorkoutActions.start(workout, tracker: tracker, now: now)

        #expect(workout.startedAt == now)
        #expect(tracker.startedAt == now)
    }

    @Test func endSetsEndedAtAndStoresTrackerEnergy() async throws {
        let workout = Workout(startedAt: Date(timeIntervalSince1970: 1_000))
        let tracker = FakeTracker()
        tracker.energy = 321
        let now = Date(timeIntervalSince1970: 2_000)

        await WorkoutActions.end(workout, tracker: tracker, now: now)

        #expect(workout.endedAt == now)
        #expect(tracker.endedAt == now)
        #expect(workout.activeEnergyKcal == 321)
        #expect(workout.isFinished)
    }

    @Test func emptyUnstartedDraftIsDiscarded() throws {
        let context = try makeContext()
        let draft = Workout()
        context.insert(draft)

        WorkoutActions.discardIfEmptyDraft(draft, context: context)

        #expect(try context.fetchCount(FetchDescriptor<Workout>()) == 0)
    }

    @Test func startedOrNonEmptyWorkoutIsKept() throws {
        let context = try makeContext()
        let started = Workout(startedAt: .now)
        let withEntry = Workout()
        context.insert(started)
        context.insert(withEntry)
        context.insert(WorkoutEntry(order: 1, workout: withEntry, exercise: Exercise(name: "Bench")))

        WorkoutActions.discardIfEmptyDraft(started, context: context)
        WorkoutActions.discardIfEmptyDraft(withEntry, context: context)

        #expect(try context.fetchCount(FetchDescriptor<Workout>()) == 2)
    }
}
