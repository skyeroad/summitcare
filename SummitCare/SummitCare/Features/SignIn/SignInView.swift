// SummitCare/Features/SignIn/SignInView.swift: passkey sign-in (Solutions 1 and 2)
import AuthenticationServices
import SwiftUI
import UIKit

struct SignInView: View {
    @Environment(AppModel.self) private var model
    @State private var failed = false

    var body: some View {
        VStack(spacing: 12) {
            Button("Sign In with a Passkey") { Task { await signIn() } }
                .buttonStyle(.borderedProminent)
            if failed {
                Text("Sign-in didn't finish. Please try again.").font(.footnote).foregroundStyle(.secondary)
            }
        }
    }

    private func signIn() async {
        guard let anchor = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first else { return }
        do {
            let challenge = try await model.apiClient.passkeyChallenge()
            let assertion = try await PasskeyAuthenticator(anchor: anchor).signIn(challenge: challenge.challenge)
            try await model.apiClient.signIn(challengeID: challenge.challengeId, assertion: assertion,
                                             deviceName: UIDevice.current.name)
            model.sessionManager.didSignIn()
            await Analytics.shared.record(.signInSucceeded)
            failed = false
        } catch {
            failed = true
        }
    }
}
