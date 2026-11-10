import Foundation

struct StatPoint: Equatable {
    let date: Date
    let count: Int
    let weightKg: Double
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

    /// Running totals: a zero point at `from`, one point per finished workout (oldest first), and a final point at `now`.
    static func cumulative(_ ws: [Workout], bodyweightKg: Double, from: Date, now: Date = .now) -> [StatPoint] {
        var points = [StatPoint(date: from, count: 0, weightKg: 0)]
        for w in ws.filter({ $0.endedAt != nil }).sorted(by: { $0.endedAt! < $1.endedAt! }) {
            let last = points[points.count - 1]
            points.append(StatPoint(date: w.endedAt!, count: last.count + 1, weightKg: last.weightKg + totalWeight(w, bodyweightKg: bodyweightKg)))
        }
        let last = points[points.count - 1]
        points.append(StatPoint(date: now, count: last.count, weightKg: last.weightKg))
        return points
    }
}
