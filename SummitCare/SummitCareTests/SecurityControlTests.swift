// SummitCareTests/SecurityControlTests.swift (Solution 35)
import CryptoKit
import Foundation
import Security
import Testing
@testable import SummitCare

@Suite("Security controls", .serialized)
struct SecurityControlTests {
    @Test("Keychain items never leave this device")
    func tokenAccessibility() throws {
        let store = TokenStore()
        try store.saveAccessToken("synthetic-access")
        _ = try store.deviceID()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true
        ]
        var result: CFTypeRef?
        #expect(SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess)
        let items = try #require(result as? [[String: Any]])
        let thisDeviceOnly = Set([kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                  kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                                  kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly].map { $0 as String })
        #expect(!items.isEmpty)
        for item in items {
            #expect(thisDeviceOnly.contains(item[kSecAttrAccessible as String] as? String ?? ""))
        }
        store.clear()
    }

    @Test("API session caches nothing on disk and requires TLS 1.2+")
    func ephemeralSession() {
        let configuration = APIClient.makeSessionConfiguration()
        #expect((configuration.urlCache?.diskCapacity ?? 0) == 0)
        #expect(configuration.tlsMinimumSupportedProtocolVersion.rawValue
                >= tls_protocol_version_t.TLSv12.rawValue)
    }

    // Not in the book: Solution 23's host allowlist.
    @Test("PHI requests go only to BAA-covered hosts")
    func outboundHosts() throws {
        try AllowedHosts.check(URL(string: "https://api.summitcare.example/api/v1/patients")!)
        #expect(throws: OutboundHostError.self) {
            try AllowedHosts.check(URL(string: "https://analytics.vendor.example/collect")!)
        }
    }

    // Not in the book: Solution 16's checksum comparison.
    @Test("Document checksums must match exactly")
    func documentChecksum() {
        let data = Data("synthetic".utf8)
        let hex = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        #expect(DocumentVerifier.matches(data, expectedSHA256: hex))
        #expect(DocumentVerifier.matches(data, expectedSHA256: hex.uppercased()))
        #expect(!DocumentVerifier.matches(Data("tampered".utf8), expectedSHA256: hex))
    }
}
