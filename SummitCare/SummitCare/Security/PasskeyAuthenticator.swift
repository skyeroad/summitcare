// SummitCare/Security/PasskeyAuthenticator.swift (Solution 2)
import AuthenticationServices

struct PasskeyAssertion: Sendable {
    let credentialID, clientDataJSON, authenticatorData, signature, userID: Data
}

@MainActor
final class PasskeyAuthenticator: NSObject {
    private var continuation: CheckedContinuation<PasskeyAssertion, any Error>?
    private var controller: ASAuthorizationController?
    private let anchor: ASPresentationAnchor

    init(anchor: ASPresentationAnchor) { self.anchor = anchor }

    func signIn(challenge: Data) async throws -> PasskeyAssertion {
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
            relyingPartyIdentifier: "summitcare.example")
        let request = provider.createCredentialAssertionRequest(challenge: challenge)
        request.userVerificationPreference = .required
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.controller = controller
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            controller.performRequests()
        }
    }

    fileprivate func finish(_ result: Result<PasskeyAssertion, any Error>) {
        continuation?.resume(with: result)
        continuation = nil
        controller = nil
    }
}

extension PasskeyAuthenticator: ASAuthorizationControllerDelegate,
                                ASAuthorizationControllerPresentationContextProviding {
    nonisolated func authorizationController(controller: ASAuthorizationController,
            didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential
                as? ASAuthorizationPlatformPublicKeyCredentialAssertion else {
            MainActor.assumeIsolated { finish(.failure(CancellationError())) }
            return
        }
        let assertion = PasskeyAssertion(
            credentialID: credential.credentialID,
            clientDataJSON: credential.rawClientDataJSON,
            authenticatorData: credential.rawAuthenticatorData,
            signature: credential.signature,
            userID: credential.userID)
        MainActor.assumeIsolated { finish(.success(assertion)) }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController,
            didCompleteWithError error: any Error) {
        MainActor.assumeIsolated { finish(.failure(error)) }
    }

    nonisolated func presentationAnchor(for controller: ASAuthorizationController)
            -> ASPresentationAnchor {
        MainActor.assumeIsolated { anchor }
    }
}
