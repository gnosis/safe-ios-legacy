//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

// MARK: - Factory methods for incoming messages.
public extension Message {

    /// Creates message from json dictionary
    ///
    /// - Parameter userInfo: json dictionary (usually from push notification)
    /// - Returns: message, if dictionary contains valid serialized message
    static func create(userInfo: [AnyHashable: Any]) -> Message? {
        if let message = TransactionConfirmedMessage(userInfo: userInfo) {
            return message
        } else if let message = TransactionRejectedMessage(userInfo: userInfo) {
            return message
        } else if let message = SendTransactionMessage(userInfo: userInfo) {
            return message
        }
        return nil
    }

}
