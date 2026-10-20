import SwiftUI

struct RootView: View {
    @Environment(\.tracker) private var tracker

    var body: some View {
        TabView {
            Tab("Start", systemImage: "figure.strengthtraining.traditional") {
                NavigationStack { StartView() }
            }
            Tab("Statistics", systemImage: "chart.bar") {
                NavigationStack { StatisticsView() }
            }
            Tab("Settings", systemImage: "gear") {
                NavigationStack { SettingsView() }
            }
        }
        .task { await tracker.requestAuthorization() }
    }
}
