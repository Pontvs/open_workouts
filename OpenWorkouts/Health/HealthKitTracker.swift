import HealthKit
import OSLog

@MainActor
final class HealthKitTracker: WorkoutTracking {
    private static let log = Logger(subsystem: "se.openworkouts.app", category: "HealthKit")

    let store = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    static func configuration() -> HKWorkoutConfiguration {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        return configuration
    }

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        do {
            try await store.requestAuthorization(
                toShare: [HKObjectType.workoutType(), HKQuantityType(.activeEnergyBurned)],
                read: [HKQuantityType(.activeEnergyBurned), HKQuantityType(.bodyMass)]
            )
        } catch {
            Self.log.error("HealthKit authorization failed: \(error)")
        }
    }

    func start(at date: Date) async {
        let configuration = Self.configuration()
        do {
            let session = try HKWorkoutSession(healthStore: store, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: store, workoutConfiguration: configuration)
            self.session = session
            self.builder = builder
            session.startActivity(with: date)
            try await builder.beginCollection(at: date)
        } catch {
            Self.log.error("Failed to start HealthKit workout: \(error)")
            // Ends a session that started but whose builder failed, so Health doesn't keep tracking.
            session?.end()
            session = nil
            builder = nil
        }
    }

    func end(at date: Date) async -> Double? {
        guard let session, let builder else { return nil }
        self.session = nil
        self.builder = nil
        session.end()
        do {
            try await builder.endCollection(at: date)
            _ = try await builder.finishWorkout()
            return builder.statistics(for: HKQuantityType(.activeEnergyBurned))?
                .sumQuantity()?
                .doubleValue(for: .kilocalorie())
        } catch {
            Self.log.error("Failed to save HealthKit workout: \(error)")
            return nil
        }
    }
}
