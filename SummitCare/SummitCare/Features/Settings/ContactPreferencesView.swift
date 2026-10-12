// SummitCare/Features/Settings/ContactPreferencesView.swift (Solution 21)
import SwiftUI

struct ContactPreferencesView: View {
    @Bindable var model: ContactPreferencesModel

    var body: some View {
        Form {
            Section {
                Toggle("Contact me only at the addresses below", isOn: $model.confidential)
                TextField("Email", text: $model.alternateEmail)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            } footer: {
                Text("SummitCare will stop using your other phone numbers and email addresses for notices.")
            }
            Toggle("Show message previews in notifications", isOn: $model.allowMessagePreview)
        }
        .navigationTitle("How We Contact You")
    }
}
