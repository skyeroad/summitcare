// SummitCare/App/AppModel.swift: root state (Solutions 3, 5, 11, 30)
import Foundation
import Observation
import SwiftData

@Observable @MainActor
final class AppModel {
    let tokenStore = TokenStore()
    let apiClient: APIClient
    let biometricGate: BiometricGate
    let sessionManager: SessionManager
    let modelContainer: ModelContainer
    var patient: Patient?
    var notice: String?

    var showsNotice: Bool {
        get { notice != nil }
        set { if !newValue { notice = nil } }
    }

    init() {
        apiClient = APIClient(tokenStore: tokenStore)
        biometricGate = BiometricGate(tokenStore: tokenStore)
        sessionManager = SessionManager(state: tokenStore.hasRefreshToken() ? .locked : .signedOut)
        do {
            modelContainer = try makeModelContainer()
        } catch {
            // Never fall back to an unprotected on-disk store.
            modelContainer = try! ModelContainer(for: CachedAppointment.self,
                                                 configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        }
    }

    /// Loads the signed-in patient's own chart (the API scopes it, Solution 4).
    func loadPatient() async {
        do {
            patient = try await apiClient.send(Endpoints.patients(), as: [Patient].self).first
        } catch {
            await handle(error)
        }
    }

    func handle(_ error: any Error) async {
        guard case APIClient.APIError.deviceRevoked = error else { return }
        await sessionManager.signOut(apiClient: apiClient, modelContainer: modelContainer)
        notice = "This device was signed out of SummitCare. Sign in again to continue."
    }

    func signOut() async {
        await sessionManager.signOut(apiClient: apiClient, modelContainer: modelContainer)
        patient = nil
    }
}
