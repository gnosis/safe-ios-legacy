//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import Common

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
        case incoming
    }

    public let id: String
    public let sender: String
    public let recipient: String
    public let amountTokenData: TokenData
    public let feeTokenData: TokenData
    public let status: Status
    public let type: TransactionType
    public let created: Date?
    public let updated: Date?
    public let submitted: Date?
    public let rejected: Date?
    public let processed: Date?

    public var displayDate: Date? {
        return [processed, rejected, submitted, updated, created].compactMap { $0 }.first
    }

    public init(id: String,
                sender: String,
                recipient: String,
                amountTokenData: TokenData,
                feeTokenData: TokenData,
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
        self.amountTokenData = amountTokenData
        self.feeTokenData = feeTokenData
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
