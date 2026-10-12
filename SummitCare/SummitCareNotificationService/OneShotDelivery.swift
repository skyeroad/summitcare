// SummitCareNotificationService/OneShotDelivery.swift (Solution 24)
import Foundation
import UserNotifications

enum PreviewOutcome: Sendable {
    case generic
    case preview(MessagePreview)
}

final class OneShotDelivery: @unchecked Sendable {   // all state guarded by `lock`
    private let lock = NSLock()
    private var handler: ((UNNotificationContent) -> Void)?

    init(_ handler: @escaping (UNNotificationContent) -> Void) { self.handler = handler }

    func deliver(_ outcome: PreviewOutcome) {
        let handler = lock.withLock { () -> ((UNNotificationContent) -> Void)? in
            defer { self.handler = nil }
            return self.handler
        }
        guard let handler else { return }
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.threadIdentifier = "messages"
        switch outcome {
        case .generic:
            content.title = "SummitCare"
            content.body = "You have a new message in SummitCare."
        case .preview(let preview):
            content.title = preview.title
            content.body = preview.body
        }
        handler(content)
    }
}
