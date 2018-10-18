//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public struct TransactionGroupData {

    public enum GroupType: String {
        case pending
        case processed
    }

    public let type: GroupType
    public let date: Date?
    public let transactions: [TransactionData]

    public init(type: GroupType, date: Date?, transactions: [TransactionData]) {
        self.type = type
        self.date = date
        self.transactions = transactions
    }
}

public struct TransactionData {

    public let id: String
    public let sender: String
    public let recipient: String
    public let amount: BigInt
    public let token: String
    public let fee: BigInt
    public let status: Status

    public init(id: String,
                sender: String,
                recipient: String,
                amount: BigInt,
                token: String,
                fee: BigInt,
                status: Status) {
        self.id = id
        self.sender = sender
        self.recipient = recipient
        self.amount = amount
        self.token = token
        self.fee = fee
        self.status = status
    }

    public enum Status {
        case waitingForConfirmation
        case rejected
        case readyToSubmit
        case pending
        case failed
        case success
        case discarded
    }

}
