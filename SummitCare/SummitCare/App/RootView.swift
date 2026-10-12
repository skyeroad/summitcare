// SummitCare/App/RootView.swift
import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(SessionManager.self) private var session
    @State private var capturing = false

    var body: some View {
        @Bindable var model = model
        TabView {
            Tab("Messages", systemImage: "bubble.left.and.bubble.right") { NavigationStack { MessagesView() } }
            Tab("Lab Results", systemImage: "testtube.2") { NavigationStack { LabResultsView() } }
            Tab("Records", systemImage: "doc.text") { NavigationStack { RecordsScreen() } }
            Tab("Settings", systemImage: "gear") { NavigationStack { SettingsView() } }
        }
        // Solution 12: hide PHI while the screen is being recorded or mirrored.
        .blur(radius: capturing ? 30 : 0)
        .background(CaptureStateReader { capturing = $0 })
        .task(id: session.state) {
            if session.state == .active, model.patient == nil { await model.loadPatient() }
        }
        .alert(model.notice ?? "", isPresented: $model.showsNotice) { Button("OK") {} }
    }
}
