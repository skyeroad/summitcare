// SummitCare/App/SummitCareApp.swift (Solutions 5 and 11)
import SwiftData
import SwiftUI

@main
struct SummitCareApp: App {
    // One SessionManager, owned by AppModel, so AppModel.handle(_:) (Solution 30)
    // signs out the same instance the views observe.
    @State private var model = AppModel()
    @Environment(\.scenePhase) private var scenePhase

    private var session: SessionManager { model.sessionManager }

    var body: some Scene {
        WindowGroup {
            RootView()
                .privacyShield()
                .simultaneousGesture(TapGesture().onEnded { session.recordActivity() })
                .onChange(of: session.state) { _, state in
                    if state != .active { Task { await model.apiClient.lock() } }
                }
                .task { session.startIdleMonitor() }
                .environment(session)
                .environment(model)
                .modelContainer(model.modelContainer)
        }
        .onChange(of: scenePhase) { _, phase in session.scenePhaseChanged(to: phase) }
    }
}

@MainActor
func makeModelContainer() throws -> ModelContainer {
    let directory = URL.applicationSupportDirectory.appending(path: "Store", directoryHint: .isDirectory)
    try FileManager.default.createDirectory(
        at: directory, withIntermediateDirectories: true,
        attributes: [.protectionKey: FileProtectionType.complete])
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    var target = directory
    try target.setResourceValues(values)

    let configuration = ModelConfiguration(
        url: directory.appending(path: "SummitCare.store"), cloudKitDatabase: .none)
    return try ModelContainer(for: CachedAppointment.self, configurations: configuration)
}
