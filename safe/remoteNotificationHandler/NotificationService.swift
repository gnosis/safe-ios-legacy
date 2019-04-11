//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let content = bestAttemptContent {
            if content.userInfo["type"] as? String == "sendTransaction" {
                content.title = NSLocalizedString("notification.sendTransaction.title",
                                                  comment: "Send Transaction Title")
                content.body = NSLocalizedString("notification.sendTransaction.body",
                                                 comment: "Send Transaction Body")
            }
            contentHandler(content)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content,
        // otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
