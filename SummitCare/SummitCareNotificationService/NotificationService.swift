// SummitCareNotificationService/NotificationService.swift (Solution 24)
import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
    private var delivery: OneShotDelivery?
    private var fetchTask: Task<Void, Never>?

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        let delivery = OneShotDelivery(contentHandler)
        self.delivery = delivery
        let messageID = request.content.userInfo["message_id"] as? String

        fetchTask = Task {
            guard let messageID, let token = TokenStore().readAccessToken(),
                  let preview = try? await PreviewFetcher.fetch(messageID: messageID, token: token)
            else {
                delivery.deliver(.generic)
                return
            }
            delivery.deliver(.preview(preview))
        }
    }

    override func serviceExtensionTimeWillExpire() {
        fetchTask?.cancel()
        delivery?.deliver(.generic)
    }
}
