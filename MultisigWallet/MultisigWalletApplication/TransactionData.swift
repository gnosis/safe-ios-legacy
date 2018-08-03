//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public struct TransactionData {

    public let id: String
    public let sender: String
    public let recipient: String
    public let amount: BigInt
    public let token: String
    public let fee: BigInt

    public init(id: String,
                sender: String,
                recipient: String,
                amount: BigInt,
                token: String,
                fee: BigInt) {
        self.id = id
        self.sender = sender
        self.recipient = recipient
        self.amount = amount
        self.token = token
        self.fee = fee
    }

}
