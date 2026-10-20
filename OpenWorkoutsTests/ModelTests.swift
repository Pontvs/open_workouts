import Foundation
import SwiftData
import Testing
@testable import OpenWorkouts

@MainActor
struct ModelTests {
    @Test func exerciseEnumAccessorsRoundTrip() {
        let exercise = Exercise()
        exercise.category = .cardio
        exercise.trackedFields = [.distance, .time]
        exercise.bodyweightMode = .assisted
        exercise.primaryMuscles = [.back, .biceps]
        exercise.secondaryMuscles = [.forearms]
        exercise.equipment = .resistanceBand

        #expect(exercise.categoryRaw == "cardio")
        #expect(exercise.category == .cardio)
        #expect(exercise.trackedFields == [.distance, .time])
        #expect(exercise.bodyweightMode == .assisted)
        #expect(exercise.primaryMuscles == [.back, .biceps])
        #expect(exercise.secondaryMuscles == [.forearms])
        #expect(exercise.equipment == .resistanceBand)
    }

    @Test func sortedEntriesAndSetsFollowOrder() throws {
        let context = try makeContext()
        let workout = Workout()
        context.insert(workout)
        let second = WorkoutEntry(order: 2, workout: workout)
        let first = WorkoutEntry(order: 1, workout: workout)
        context.insert(second)
        context.insert(first)
        let setB = WorkoutSet(order: 2, entry: first)
        let setA = WorkoutSet(order: 1, entry: first)
        context.insert(setB)
        context.insert(setA)

        #expect(workout.sortedEntries.map(\.order) == [1, 2])
        #expect(first.sortedSets.map(\.order) == [1, 2])
    }

    @Test func profileCurrentIsSingleton() throws {
        let context = try makeContext()
        let first = Profile.current(in: context)
        let second = Profile.current(in: context)

        #expect(first.persistentModelID == second.persistentModelID)
        #expect(try context.fetchCount(FetchDescriptor<Profile>()) == 1)
    }

    @Test func sinceStartDates() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let calendar = Calendar.current

        #expect(Since.allTime.startDate(from: now) == nil)
        #expect(Since.threeMonths.startDate(from: now) == calendar.date(byAdding: .month, value: -3, to: now))
        #expect(Since.oneYear.startDate(from: now) == calendar.date(byAdding: .year, value: -1, to: now))
        #expect(Since.threeYears.startDate(from: now) == calendar.date(byAdding: .year, value: -3, to: now))
    }

    @Test func deletingWorkoutCascadesToEntriesAndSets() throws {
        let context = try makeContext()
        let workout = Workout()
        context.insert(workout)
        let entry = WorkoutEntry(order: 0, workout: workout)
        context.insert(entry)
        context.insert(WorkoutSet(order: 0, entry: entry))
        try context.save()

        context.delete(workout)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<WorkoutEntry>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<WorkoutSet>()) == 0)
    }
}
