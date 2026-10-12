// SummitCare/Networking/APIClient.swift (Solutions 3, 10, 23, 30)
import Foundation

actor APIClient {
    enum APIError: Error { case signedOut, deviceRevoked, http(Int) } // deviceRevoked: Solution 30

    private let session = URLSession(configuration: APIClient.makeSessionConfiguration())
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase   // expires_at -> expiresAt
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    private let tokenStore: TokenStore
    private var accessToken: String?
    private var refreshToken: String?   // set by unlock(refreshToken:), cleared by lock()
    private var refreshTask: Task<String, any Error>?

    init(tokenStore: TokenStore) { self.tokenStore = tokenStore }

    // Solution 10 replaces the Solution 3 stub (`.ephemeral`) with this.
    static func makeSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        configuration.urlCache = nil
        return configuration
    }

    func unlock(refreshToken: String) { self.refreshToken = refreshToken }
    func lock() { accessToken = nil; refreshToken = nil }
}

extension APIClient {
    func send<T: Decodable & Sendable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        guard let url = request.url else { throw URLError(.badURL) }
        try AllowedHosts.check(url) // Solution 23
        var token = try await currentAccessToken()
        for attempt in 0..<2 {
            var authorized = request
            authorized.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let (data, response) = try await session.data(for: authorized)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            if let http = response as? HTTPURLResponse { try checkRevocation(http, data: data) } // Solution 30
            if status == 401, attempt == 0 {
                token = try await refreshedAccessToken(replacing: token)
                continue
            }
            guard (200..<300).contains(status) else { throw APIError.http(status) }
            return try decoder.decode(T.self, from: data)
        }
        throw APIError.signedOut
    }
}

extension APIClient {
    private func currentAccessToken() async throws -> String {
        if let accessToken { return accessToken }
        return try await refreshedAccessToken(replacing: nil)
    }

    private func refreshedAccessToken(replacing rejected: String?) async throws -> String {
        if let accessToken, accessToken != rejected { return accessToken } // already refreshed
        if let refreshTask { return try await refreshTask.value }
        let task = Task { try await performRefresh() }
        refreshTask = task
        defer { refreshTask = nil }
        return try await task.value
    }
}

extension APIClient {
    private func performRefresh() async throws -> String {
        guard let refreshToken else { throw APIError.signedOut }
        let body = RefreshRequest(refreshToken: refreshToken, deviceID: try tokenStore.deviceID())
        let request = try Endpoints.tokenRefresh(body)
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse { try checkRevocation(http, data: data) } // Solution 30
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            accessToken = nil; self.refreshToken = nil
            throw APIError.signedOut
        }
        let pair = try decoder.decode(TokenPair.self, from: data)
        accessToken = pair.accessToken
        self.refreshToken = pair.refreshToken
        try tokenStore.saveRefreshToken(pair.refreshToken)
        try tokenStore.saveAccessToken(pair.accessToken) // for the notification extension (Solution 24)
        return pair.accessToken
    }
}

extension APIClient {
    private struct ErrorBody: Decodable { let error: String }

    // send(_:as:) and performRefresh() call this before their other status checks.
    func checkRevocation(_ response: HTTPURLResponse, data: Data) throws {
        guard response.statusCode == 401,
              let body = try? JSONDecoder().decode(ErrorBody.self, from: data),
              body.error == "device_revoked" else {
            return
        }
        accessToken = nil; refreshToken = nil
        throw APIError.deviceRevoked
    }
}

// MARK: - Sign-in (Solutions 1 and 2). These requests carry no bearer token.

extension APIClient {
    struct PasskeyChallenge: Sendable {
        let challengeId: String
        let challenge: Data
    }

    func passkeyChallenge() async throws -> PasskeyChallenge {
        let (data, response) = try await session.data(for: Endpoints.newPasskeySession())
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw APIError.signedOut }
        let options = try decoder.decode(PasskeyOptionsEnvelope.self, from: data)
        guard let challenge = Data(base64URLEncoded: options.options.challenge) else {
            throw URLError(.cannotParseResponse)
        }
        return PasskeyChallenge(challengeId: options.challengeId, challenge: challenge)
    }

    /// Exchanges a passkey assertion for tokens, then stores them (Solutions 2, 3).
    func signIn(challengeID: String, assertion: PasskeyAssertion, deviceName: String) async throws {
        let body = PasskeySignInRequest(challengeID: challengeID, assertion: assertion,
                                        deviceID: try tokenStore.deviceID(), deviceName: deviceName)
        let (data, response) = try await session.data(for: try Endpoints.passkeySession(body))
        guard (response as? HTTPURLResponse)?.statusCode == 201 else { throw APIError.signedOut }
        let pair = try decoder.decode(TokenPair.self, from: data)
        try tokenStore.saveRefreshToken(pair.refreshToken)
        try tokenStore.saveAccessToken(pair.accessToken)
        accessToken = pair.accessToken
        refreshToken = pair.refreshToken
    }

    private struct PasskeyOptionsEnvelope: Decodable {
        struct Options: Decodable { let challenge: String }
        let challengeId: String
        let options: Options
    }
}

// MARK: - Downloads that don't go through send(_:as:)

extension APIClient {
    /// Fetches a fulfilled record export (Solution 18). The ticket comes from the
    /// API; the file itself comes from the short-lived URL, without the bearer token.
    func downloadRecordExport(patientID: Patient.ID, file: RecordExportFile) async throws -> Data {
        let ticket = try await send(Endpoints.recordExport(patientID: patientID, file: file),
                                    as: RecordExportTicket.self)
        let (data, response) = try await session.data(from: ticket.url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return data
    }

    func createAmendmentRequest(_ draft: AmendmentDraft) async throws {
        _ = try await send(try Endpoints.createAmendmentRequest(draft), as: AmendmentRequestReceipt.self)
    }
}
