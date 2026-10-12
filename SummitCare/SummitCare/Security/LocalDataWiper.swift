// SummitCare/Security/LocalDataWiper.swift (Solution 11): the only wipe path.
import Foundation
import SwiftData
import UserNotifications

enum LocalDataWiper {
    @MainActor
    static func wipeAll(modelContainer: ModelContainer) {
        TokenStore().clear()
        try? ProtectedFileStore.shared.purgeAll()
        modelContainer.deleteAllData() // iOS 18+
        try? FileManager.default.removeItem(at: URL.applicationSupportDirectory.appending(path: "Store"))
        URLCache.shared.removeAllCachedResponses()
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
