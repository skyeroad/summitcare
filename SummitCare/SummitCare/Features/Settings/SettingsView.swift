// SummitCare/Features/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var preferences = ContactPreferencesModel()

    var body: some View {
        List {
            NavigationLink("How We Contact You") { ContactPreferencesView(model: preferences) }
            Section {
                Button("Sign Out", role: .destructive) { Task { await model.signOut() } }
            } footer: {
                Text("Signing out removes your records and messages from this iPhone.")
            }
        }
        .navigationTitle("Settings")
    }
}
