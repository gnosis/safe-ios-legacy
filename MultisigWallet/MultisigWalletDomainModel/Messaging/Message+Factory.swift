//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

extension Message {

    static func create(userInfo: [AnyHashable: Any]) -> Message? {
        if let message = TransactionConfirmedMessage(userInfo: userInfo) {
            return message
        } else if let message = TransactionRejectedMessage(userInfo: userInfo) {
            return message
        }
        return nil
    }

}
