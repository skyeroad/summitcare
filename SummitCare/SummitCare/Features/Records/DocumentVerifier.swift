// SummitCare/Features/Records/DocumentVerifier.swift (Solution 16)
import CryptoKit
import Foundation

enum DocumentVerifier {
    static func matches(_ data: Data, expectedSHA256 hex: String) -> Bool {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined() == hex.lowercased()
    }
}
