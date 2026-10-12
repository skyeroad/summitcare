// SummitCare/Security/SessionManager.swift (Solutions 5 and 11)
import SwiftData
import SwiftUI

@Observable @MainActor
final class SessionManager {
    enum State { case signedOut, locked, active }

    private(set) var state: State
    let idleLimit: TimeInterval
    let backgroundGrace: TimeInterval
    @ObservationIgnored private var lastActivity = Date.now
    @ObservationIgnored private var backgroundedAt: Date?
    @ObservationIgnored private var idleTask: Task<Void, Never>?

    init(state: State = .signedOut, idleLimit: TimeInterval = 300, backgroundGrace: TimeInterval = 30) {
        self.state = state
        self.idleLimit = idleLimit
        self.backgroundGrace = backgroundGrace
    }

    func recordActivity(at now: Date = .now) { lastActivity = now }

    func checkIdle(at now: Date = .now) {
        if state == .active, now.timeIntervalSince(lastActivity) >= idleLimit { state = .locked }
    }
}

extension SessionManager {
    func scenePhaseChanged(to phase: ScenePhase, at now: Date = .now) {
        switch phase {
        case .background: backgroundedAt = now
        case .active:
            if let backgroundedAt, now.timeIntervalSince(backgroundedAt) >= backgroundGrace,
               state == .active { state = .locked }
            backgroundedAt = nil
            checkIdle(at: now)
        default: break // .inactive: PrivacyShield covers the screen
        }
    }
}

extension SessionManager {
    func startIdleMonitor() {
        idleTask?.cancel()
        idleTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(15))
                self?.checkIdle()
            }
        }
    }

    func unlock(gate: BiometricGate, apiClient: APIClient) async throws {
        let refreshToken = try await gate.unlockRefreshToken()
        await apiClient.unlock(refreshToken: refreshToken)
        recordActivity()
        state = .active
    }

    /// After a full passkey sign-in, which already put fresh tokens in APIClient.
    func didSignIn() {
        recordActivity()
        state = .active
    }
}

extension SessionManager {
    func signOut(apiClient: APIClient, modelContainer: ModelContainer) async {
        await apiClient.lock()
        LocalDataWiper.wipeAll(modelContainer: modelContainer)
        state = .signedOut
    }
}
