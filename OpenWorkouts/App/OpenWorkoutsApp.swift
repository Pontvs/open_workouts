import SwiftUI
import SwiftData

@main
struct OpenWorkoutsApp: App {
    let container: ModelContainer
    let tracker: any WorkoutTracking

    init() {
        let inMemory = ProcessInfo.processInfo.arguments.contains("-uiTesting")
            || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        tracker = inMemory ? NoopTracker() : HealthKitTracker()
        let configuration = inMemory
            ? ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            : ModelConfiguration(cloudKitDatabase: .automatic)
        do {
            container = try ModelContainer(
                for: Exercise.self, Workout.self, WorkoutEntry.self, WorkoutSet.self, Profile.self,
                configurations: configuration
            )
            try Seed.seedIfNeeded(container.mainContext)
        } catch {
            fatalError("Failed to set up SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.tracker, tracker)
        }
        .modelContainer(container)
    }
}
