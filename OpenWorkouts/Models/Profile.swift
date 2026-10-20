import SwiftData

@Model
final class Profile {
    var age: Int = 30
    var gender: String = ""
    var weightKg: Double = 75
    var heightCm: Double = 175
    var goal: String = ""

    init() {}

    static func current(in context: ModelContext) -> Profile {
        if let existing = try? context.fetch(FetchDescriptor<Profile>()).first {
            return existing
        }
        let profile = Profile()
        context.insert(profile)
        return profile
    }
}
