// SummitCare/Networking/Endpoints.swift: builds URLRequests (Solutions 3, 9, 18, 20)
import Foundation

struct RefreshRequest: Encodable, Sendable {
    let refreshToken: String
    let deviceID: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case deviceID = "device_id"
    }
}

struct TokenPair: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

struct PasskeySignInRequest: Encodable, Sendable {
    let challengeID: String
    let assertion: PasskeyAssertion
    let deviceID: String
    let deviceName: String

    enum CodingKeys: String, CodingKey {
        case challengeID = "challenge_id", credential, deviceID = "device_id", deviceName = "device_name"
    }

    // The WebAuthn PublicKeyCredential JSON the server's webauthn gem expects.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(challengeID, forKey: .challengeID)
        try container.encode(deviceID, forKey: .deviceID)
        try container.encode(deviceName, forKey: .deviceName)
        let id = assertion.credentialID.base64URLEncodedString()
        try container.encode([
            "type": AnyEncodable("public-key"), "id": AnyEncodable(id), "rawId": AnyEncodable(id),
            "authenticatorAttachment": AnyEncodable("platform"),
            "clientExtensionResults": AnyEncodable([String: String]()),
            "response": AnyEncodable([
                "clientDataJSON": assertion.clientDataJSON.base64URLEncodedString(),
                "authenticatorData": assertion.authenticatorData.base64URLEncodedString(),
                "signature": assertion.signature.base64URLEncodedString(),
                "userHandle": assertion.userID.base64URLEncodedString()
            ])
        ], forKey: .credential)
    }
}

struct AnyEncodable: Encodable, Sendable {
    private let encodeValue: @Sendable (any Encoder) throws -> Void
    init<T: Encodable & Sendable>(_ value: T) { encodeValue = { try value.encode(to: $0) } }
    func encode(to encoder: any Encoder) throws { try encodeValue(encoder) }
}

enum RecordExportFile: String, Sendable, CaseIterable {
    case fhir, pdf

    var filename: String { self == .pdf ? "SummitCare-Records.pdf" : "SummitCare-Records.json" }
}

struct RecordExportTicket: Decodable, Sendable { let url: URL }
struct RecordExportReceipt: Decodable, Sendable { let id: Int; let dueOn: String }

struct AmendmentTarget: Sendable, Hashable {
    let type: String   // "LabResult", "Appointment", or "Document"
    let id: Int
    let patientID: Patient.ID
}

struct AmendmentDraft: Encodable, Sendable {
    let target: AmendmentTarget
    let requestedChange: String
    let reason: String

    enum CodingKeys: String, CodingKey {
        case targetType = "target_type", targetID = "target_id"
        case requestedChange = "requested_change", reason
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(target.type, forKey: .targetType)
        try container.encode(target.id, forKey: .targetID)
        try container.encode(requestedChange, forKey: .requestedChange)
        try container.encode(reason, forKey: .reason)
    }
}

struct AmendmentRequestReceipt: Decodable, Sendable { let id: Int; let status: String; let dueOn: String }

enum Endpoints {
    static let base = URL(string: "https://api.summitcare.example/api/v1/")!

    private static func makeRequest(_ path: String, method: String = "GET", query: [URLQueryItem] = []) -> URLRequest {
        var url = base.appending(path: path)
        if !query.isEmpty { url.append(queryItems: query) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private static func json(_ path: String, method: String = "POST", body: some Encodable) throws -> URLRequest {
        var request = makeRequest(path, method: method)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    static func tokenRefresh(_ body: RefreshRequest) throws -> URLRequest { try json("token_refresh", body: body) }
    static func newPasskeySession() -> URLRequest { makeRequest("passkey_session/new") }
    static func passkeySession(_ body: PasskeySignInRequest) throws -> URLRequest { try json("passkey_session", body: body) }

    static func patients() -> URLRequest { makeRequest("patients") }
    static func labResults(patientID: Patient.ID) -> URLRequest { makeRequest("patients/\(patientID)/lab_results") }
    static func appointments(patientID: Patient.ID) -> URLRequest { makeRequest("patients/\(patientID)/appointments") }
    static func messages(patientID: Patient.ID) -> URLRequest { makeRequest("patients/\(patientID)/messages") }

    static func sendMessage(patientID: Patient.ID, body: String) throws -> URLRequest {
        try json("patients/\(patientID)/messages", body: ["message": ["body": body]])
    }

    static func document(patientID: Patient.ID, id: Int) -> URLRequest {
        makeRequest("patients/\(patientID)/documents/\(id)")
    }

    static func requestRecordExport(patientID: Patient.ID) throws -> URLRequest {
        try json("patients/\(patientID)/record_export", body: ["export_format": "both"])
    }

    static func recordExport(patientID: Patient.ID, file: RecordExportFile) -> URLRequest {
        makeRequest("patients/\(patientID)/record_export", query: [URLQueryItem(name: "file", value: file.rawValue)])
    }

    static func createAmendmentRequest(_ draft: AmendmentDraft) throws -> URLRequest {
        try json("patients/\(draft.target.patientID)/amendment_requests", body: draft)
    }
}
