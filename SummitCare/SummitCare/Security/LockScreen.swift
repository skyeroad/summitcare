// SummitCare/Security/LockScreen.swift: what PrivacyShield shows (Solutions 5, 12).
// No PHI here: it is also what the app switcher snapshot captures.
import SwiftUI

struct LockScreen: View {
    @Environment(SessionManager.self) private var session
    @Environment(AppModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase
    @State private var unlockFailed = false

    var body: some View {
        ZStack {
            Rectangle().fill(.background).ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "cross.case.fill").font(.system(size: 56)).foregroundStyle(.tint)
                Text("SummitCare").font(.largeTitle.bold())
                if scenePhase == .active {
                    switch session.state {
                    case .signedOut: SignInView()
                    case .locked:
                        Button("Unlock with Face ID") { Task { await unlock() } }
                            .buttonStyle(.borderedProminent)
                        if unlockFailed {
                            Text("Couldn't unlock. Try again, or sign in with your passkey.")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                    case .active: EmptyView()
                    }
                }
            }
            .padding()
        }
    }

    private func unlock() async {
        do {
            try await session.unlock(gate: model.biometricGate, apiClient: model.apiClient)
            unlockFailed = false
        } catch {
            unlockFailed = true
        }
    }
}
