//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import Common
import MultisigWalletDomainModel

public struct TransactionGroupData: Collection {

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

    // MARK: Collection conformance

    public var startIndex: Int {
        return transactions.startIndex
    }

    public var endIndex: Int {
        return transactions.endIndex
    }

    public subscript(index: Int) -> TransactionData {
        return transactions[index]
    }

    public func index(after i: Int) -> Int {
        return transactions.index(after: i)
    }

}

public struct TransactionData: Equatable {

    public enum TransactionType {
        case outgoing
        case incoming
        case walletRecovery
        case replaceRecoveryPhrase
        case replaceTwoFAWithAuthenticator
        case connectAuthenticator
        case disconnectAuthenticator
        case contractUpgrade
        case replaceTwoFAWithStatusKeycard
        case connectStatusKeycard
        case disconnectStatusKeycard
    }

    public let id: String
    public let walletID: String
    public let sender: String
    public let senderName: String?
    public let recipient: String
    public let recipientName: String?
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

    public static let empty = TransactionData(id: "",
                                              walletID: "",
                                              sender: "",
                                              senderName: nil,
                                              recipient: "",
                                              recipientName: nil,
                                              amountTokenData: .empty(),
                                              feeTokenData: .empty(),
                                              status: .rejected,
                                              type: .incoming,
                                              created: nil,
                                              updated: nil,
                                              submitted: nil,
                                              rejected: nil,
                                              processed: nil)

    public init(id: String,
                walletID: String,
                sender: String,
                senderName: String?,
                recipient: String,
                recipientName: String?,
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
        self.walletID = walletID
        self.sender = sender
        self.senderName = senderName
        self.recipient = recipient
        self.recipientName = recipientName
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
    }

}

extension TransactionData.TransactionType {

    var transactionType: TransactionType {
        switch self {
        case .connectStatusKeycard: return .connectStatusKeycard
        case .connectAuthenticator: return .connectAuthenticator
        case .outgoing: return .transfer
        case .incoming: return .transfer
        case .walletRecovery: return .walletRecovery
        case .replaceRecoveryPhrase: return .replaceRecoveryPhrase
        case .replaceTwoFAWithAuthenticator: return .replaceTwoFAWithAuthenticator
        case .disconnectAuthenticator: return .disconnectAuthenticator
        case .contractUpgrade: return .contractUpgrade
        case .replaceTwoFAWithStatusKeycard: return .replaceTwoFAWithStatusKeycard
        case .disconnectStatusKeycard: return .disconnectStatusKeycard
        }
    }

}

extension TransactionType {

    var transactionDataType: TransactionData.TransactionType {
        switch self {
        case .transfer: return .outgoing
        case .walletRecovery: return .walletRecovery
        case .replaceRecoveryPhrase: return .replaceRecoveryPhrase
        case .replaceTwoFAWithAuthenticator: return .replaceTwoFAWithAuthenticator
        case .connectAuthenticator: return .connectAuthenticator
        case .disconnectAuthenticator: return .disconnectAuthenticator
        case .contractUpgrade: return .contractUpgrade
        case .replaceTwoFAWithStatusKeycard: return .replaceTwoFAWithStatusKeycard
        case .connectStatusKeycard: return .connectStatusKeycard
        case .disconnectStatusKeycard: return .disconnectStatusKeycard
        case .batched:
            return .outgoing
        }
    }

}


extension TransactionStatus.Code {

    var transactionDataStatus: TransactionData.Status {
        switch self {
        case .draft: return .waitingForConfirmation
        case .signing: return .readyToSubmit
        case .pending: return .pending
        case .rejected: return .rejected
        case .failed: return .failed
        case .success: return .success
        }
    }

}

extension TransactionGroupData.GroupType {

    init(_ type: TransactionGroup.GroupType) {
        switch type {
        case .pending: self = .pending
        case .processed: self = .processed
        }
    }

}

