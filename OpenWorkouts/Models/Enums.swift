import Foundation

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case strength, cardio, mobility
    var id: Self { self }
    var title: String { rawValue.capitalized }
}

enum TrackedField: String, Codable, CaseIterable, Identifiable {
    case reps, weight, bodyweight, distance, height, time
    var id: Self { self }
    var title: String { rawValue.capitalized }
}

enum BodyweightMode: String, Codable, CaseIterable, Identifiable {
    case none, extra, assisted
    var id: Self { self }
    var title: String { rawValue.capitalized }
}

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest, back, shoulders, biceps, triceps, forearms, core, glutes, quadriceps, hamstrings, calves, fullBody
    var id: Self { self }
    var title: String {
        switch self {
        case .fullBody: "Full body"
        default: rawValue.capitalized
        }
    }
}

enum Equipment: String, Codable, CaseIterable, Identifiable {
    case barbell, dumbbell, machine, kettlebell, bodyWeight, resistanceBand, cable, other
    var id: Self { self }
    var title: String {
        switch self {
        case .bodyWeight: "Bodyweight"
        case .resistanceBand: "Resistance band"
        default: rawValue.capitalized
        }
    }
}

enum Since: String, Codable, CaseIterable, Identifiable {
    case allTime, threeYears, oneYear, sixMonths, threeMonths
    var id: Self { self }
    var title: String {
        switch self {
        case .allTime: "All time"
        case .threeYears: "3 years"
        case .oneYear: "1 year"
        case .sixMonths: "6 months"
        case .threeMonths: "3 months"
        }
    }

    /// nil means no lower bound.
    func startDate(from now: Date = .now) -> Date? {
        let months: Int
        switch self {
        case .allTime: return nil
        case .threeYears: months = 36
        case .oneYear: months = 12
        case .sixMonths: months = 6
        case .threeMonths: months = 3
        }
        return Calendar.current.date(byAdding: .month, value: -months, to: now)
    }
}
