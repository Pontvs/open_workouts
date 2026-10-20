import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            NavigationLink("Profile") { ProfileView() }
            NavigationLink("Exercises") { ExerciseListView() }
        }
        .navigationTitle("Settings")
    }
}
