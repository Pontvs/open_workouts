import Foundation

struct MonthBucket: Identifiable, Equatable {
    let month: Date
    let count: Int
    let weightKg: Double
    var id: Date { month }
}

enum WorkoutStats {
    static func duration(_ w: Workout, now: Date = .now) -> TimeInterval {
        guard let start = w.startedAt else { return 0 }
        return (w.endedAt ?? now).timeIntervalSince(start)
    }

    /// Per-rep load in kg.
    static func load(_ set: WorkoutSet, exercise: Exercise?, bodyweightKg: Double) -> Double {
        guard exercise?.trackedFields.contains(.bodyweight) == true else { return set.weightKg ?? 0 }
        return max(0, bodyweightKg + (set.extraKg ?? 0) - (set.assistKg ?? 0))
    }

    static func totalWeight(_ w: Workout, bodyweightKg: Double) -> Double {
        (w.entries ?? []).reduce(0) { total, entry in
            let sum = entry.sortedSets.reduce(0) { sum, set in
                sum + Double(set.reps ?? 0) * load(set, exercise: entry.exercise, bodyweightKg: bodyweightKg)
            }
            // Per-side sets are entered per side, so both sides count.
            return total + (entry.exercise?.perSide == true ? sum * 2 : sum)
        }
    }

    static func estimatedKcal(_ w: Workout, bodyweightKg: Double, now: Date = .now) -> Double {
        if let kcal = w.activeEnergyKcal { return kcal }
        // shortcut: MET approximation, ignores intensity; upgrade by using HealthKit energy which is preferred when present
        let mets = (w.entries ?? []).map { entry -> Double in
            switch entry.exercise?.category ?? .strength {
            case .strength: 6
            case .cardio: 8
            case .mobility: 3
            }
        }
        let met = mets.isEmpty ? 5 : mets.reduce(0, +) / Double(mets.count)
        return met * bodyweightKg * duration(w, now: now) / 3600
    }

    static func finished(_ all: [Workout], since: Since, now: Date = .now) -> [Workout] {
        let lower = since.startDate(from: now) ?? .distantPast
        return all
            .compactMap { w -> (Workout, Date)? in
                guard let ended = w.endedAt, ended >= lower else { return nil }
                return (w, ended)
            }
            .sorted { $0.1 > $1.1 }
            .map(\.0)
    }

    static func monthly(_ ws: [Workout], bodyweightKg: Double) -> [MonthBucket] {
        let calendar = Calendar.current
        var buckets: [Date: (count: Int, weightKg: Double)] = [:]
        for w in ws {
            guard let ended = w.endedAt, let month = calendar.dateInterval(of: .month, for: ended)?.start else { continue }
            let old = buckets[month, default: (0, 0)]
            buckets[month] = (old.count + 1, old.weightKg + totalWeight(w, bodyweightKg: bodyweightKg))
        }
        return buckets
            .map { MonthBucket(month: $0.key, count: $0.value.count, weightKg: $0.value.weightKg) }
            .sorted { $0.month < $1.month }
    }
}
