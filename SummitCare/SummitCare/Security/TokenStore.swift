// SummitCare/Security/TokenStore.swift (Solutions 2, 3, 11, 24)
// Compiled into both the app and SummitCareNotificationService.
import Foundation
import LocalAuthentication
import Security

struct TokenStore: Sendable {
    enum KeychainError: Error { case status(OSStatus), biometryUnavailable }
    private let service = "com.summitcare.app.tokens"

    func saveRefreshToken(_ token: String) throws {
        var error: Unmanaged<CFError>?
        guard let access = SecAccessControlCreateWithFlags(
            nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .biometryCurrentSet, &error)
        else { throw error!.takeRetainedValue() as any Error }
        let base: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrService as String: service,
                                   kSecAttrAccount as String: "refresh"]
        SecItemDelete(base as CFDictionary)
        var item = base
        item[kSecAttrAccessControl as String] = access
        item[kSecValueData as String] = Data(token.utf8)
        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.status(status) }
    }

    /// Reads the refresh token. `context` has already been given its
    /// localizedReason; the Face ID prompt appears during this call (Solution 2).
    func readRefreshToken(context: LAContext) throws -> String {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: "refresh",
                                    kSecUseAuthenticationContext as String: context,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data,
              let token = String(data: data, encoding: .utf8)
        else { throw KeychainError.status(status) }
        return token
    }

    /// Whether a refresh token exists, without showing a biometric prompt.
    func hasRefreshToken() -> Bool {
        let context = LAContext()
        context.interactionNotAllowed = true
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: "refresh",
                                    kSecUseAuthenticationContext as String: context,
                                    kSecReturnAttributes as String: true]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }

    /// A random per-install device ID, sent with sign-in and refresh (Solution 3).
    func deviceID() throws -> String {
        let base: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrService as String: service,
                                   kSecAttrAccount as String: "device-id"]
        var query = base
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
           let data = item as? Data, let id = String(data: data, encoding: .utf8) {
            return id
        }
        let id = UUID().uuidString
        var newItem = base
        newItem[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        newItem[kSecValueData as String] = Data(id.utf8)
        let status = SecItemAdd(newItem as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.status(status) }
        return id
    }
}

extension TokenStore {
    func clear() {
        for itemClass in [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassKey] {
            let query: [String: Any] = [kSecClass as String: itemClass,
                                        kSecAttrSynchronizable as String: kSecAttrSynchronizableAny]
            SecItemDelete(query as CFDictionary) // no access group: matches every group the app can use
        }
    }
}

extension TokenStore {
    private var accessTokenItem: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service,
         kSecAttrAccount as String: "access", kSecAttrAccessGroup as String: "group.com.summitcare.app"]
    }

    func saveAccessToken(_ token: String) throws {
        SecItemDelete(accessTokenItem as CFDictionary)
        var item = accessTokenItem
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        item[kSecValueData as String] = Data(token.utf8)
        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.status(status) }
    }

    func readAccessToken() -> String? {
        var query = accessTokenItem
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
