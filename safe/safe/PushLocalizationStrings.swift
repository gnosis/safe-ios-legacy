//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Localization of the incoming push notifications based on their type
enum PushLocalizationStrings {

    /// Transaction types
    ///
    /// - sendTransaction: incoming transaction request
    /// - confirmTransaction: incoming signature of a transaction from another owner
    /// - rejectTransaction: incoming decline of a transaction from another owner
    enum MessageType: String, Hashable {
        case sendTransaction
        case confirmTransaction
        case rejectTransaction
    }

    /// Data of a resulting push notification
    struct Alert {
        /// Header of a push notification
        var title: String
        /// Message of a push notification
        var body: String
    }

    /// Index of message types and their titles and messages
    private static let contents: [MessageType: Alert] = [
        .sendTransaction: Alert(title: NSLocalizedString("sign_transaction_request_title",
                                                         comment: "Title for signing request"),
                                body: NSLocalizedString("sign_transaction_request_message",
                                                        comment: "Body for signing request")),
        .confirmTransaction: Alert(title: NSLocalizedString("confirmed", comment: "Title for confirmation"),
                                   body: NSLocalizedString("ios_transaction_confirmed_message",
                                                           comment: "Body for confirmation")),
        .rejectTransaction: Alert(title: NSLocalizedString("rejected", comment: "Title for rejection"),
                                  body: NSLocalizedString("ios_transaction_rejected_message",
                                                          comment: "Body for rejection"))
    ]

    /// Provides content based on the push notification's userInfo dict
    ///
    /// - Parameter userInfo: push notification custom data
    /// - Returns: content to use based on the notficiation's custom data. Nil means the push notification content
    ///            should not be modified.
    static func alertContent(from userInfo: [AnyHashable: Any]) -> Alert? {
        guard let typeRawValue = userInfo["type"] as? String,
            let type = MessageType(rawValue: typeRawValue) else { return nil }
        return contents[type]
    }

}
