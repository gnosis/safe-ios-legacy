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

    public enum TransactionType {
        case outgoing
    }

    public let id: String
    public let sender: String
    public let recipient: String
    public let amount: BigInt
    public let token: String
    public let tokenDecimals: Int
    public let fee: BigInt
    public let feeToken: String
    public let feeTokenDecimals: Int
    public let status: Status
    public let type: TransactionType
    public let created: Date?
    public let updated: Date?
    public let submitted: Date?
    public let rejected: Date?
    public let processed: Date?

    public init(id: String,
                sender: String,
                recipient: String,
                amount: BigInt,
                token: String,
                tokenDecimals: Int,
                fee: BigInt,
                feeToken: String,
                feeTokenDecimals: Int,
                status: Status,
                type: TransactionType,
                created: Date?,
                updated: Date?,
                submitted: Date?,
                rejected: Date?,
                processed: Date?) {
        self.id = id
        self.sender = sender
        self.recipient = recipient
        self.amount = amount
        self.token = token
        self.tokenDecimals = tokenDecimals
        self.fee = fee
        self.feeToken = feeToken
        self.feeTokenDecimals = feeTokenDecimals
        self.status = status
        self.type = type
        self.created = created
        self.updated = updated
        self.submitted = submitted
        self.rejected = rejected
        self.processed = processed
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
