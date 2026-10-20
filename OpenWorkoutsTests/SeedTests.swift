import Foundation
import SwiftData
import Testing
@testable import OpenWorkouts

@MainActor
struct SeedTests {
    static func bundledData() throws -> Data {
        let url = try #require(Bundle.main.url(forResource: "exercises", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    @Test func bundledJSONDecodes() throws {
        let exercises = try Seed.load(from: Self.bundledData())
        #expect(exercises.count >= 50)
        #expect(Set(exercises.map(\.name)).count == exercises.count)
    }

    @Test func seedInsertsOnlyOnce() throws {
        let context = try makeContext()
        let expected = try Seed.load(from: Self.bundledData()).count

        try Seed.seedIfNeeded(context)
        try Seed.seedIfNeeded(context)

        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == expected)
    }
}
