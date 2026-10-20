import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ProfileForm(profile: Profile.current(in: modelContext))
    }
}

private struct ProfileForm: View {
    @Bindable var profile: Profile

    var body: some View {
        Form {
            Stepper("Age: \(profile.age)", value: $profile.age, in: 10...120)
                .accessibilityIdentifier("ageField")

            Picker("Gender", selection: $profile.gender) {
                Text("Not set").tag("")
                ForEach(["Female", "Male", "Other", "Prefer not to say"], id: \.self) { Text($0).tag($0) }
            }
            .accessibilityIdentifier("genderPicker")

            TextField("Weight (kg)", value: $profile.weightKg, format: .number)
                .keyboardType(.decimalPad)
                .accessibilityIdentifier("weightField")

            TextField("Height (cm)", value: $profile.heightCm, format: .number)
                .keyboardType(.decimalPad)
                .accessibilityIdentifier("heightField")

            TextField("Goal", text: $profile.goal, axis: .vertical)
                .accessibilityIdentifier("goalField")
        }
        .navigationTitle("Profile")
    }
}
