// SummitCare/Security/BiometricGate.swift (Solution 2)
import LocalAuthentication
import Security

struct BiometricGate: Sendable {
    let tokenStore: TokenStore

    // Runs off the main actor: SecItemCopyMatching blocks while the prompt is up.
    // With Swift 6.2's "nonisolated(nonsending) by default", mark this @concurrent.
    func unlockRefreshToken() async throws -> String {
        let context = LAContext()
        var policyError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        error: &policyError) else {
            throw TokenStore.KeychainError.biometryUnavailable
        }
        context.localizedReason = "Unlock your SummitCare health records"
        return try tokenStore.readRefreshToken(context: context)
    }
}
