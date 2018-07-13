//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class TransactionID: BaseID {}

/// Transaction represents an operation in an account of a wallet.
public class Transaction: IdentifiableEntity<TransactionID> {

    public enum Error: Swift.Error {
        case invalidStatusForEditing(TransactionStatus)
        case invalidStatusForSigning(TransactionStatus)
        case invalidStatusForSetHash(TransactionStatus)
        case invalidStatusForTimestamp(TransactionStatus)
        case invalidStatusTransition(from: TransactionStatus, to: TransactionStatus)
        case senderNotSet
        case recipientNotSet
        case amountNotSet
        case feeNotSet
        case transactionHashNotSet
    }

    // MARK: - Querying transaction data

    public let type: TransactionType
    public private(set) var sender: BlockchainAddress?
    public private(set) var recipient: BlockchainAddress?
    public private(set) var amount: TokenAmount?
    public private(set) var fee: TokenAmount?
    public private(set) var status: TransactionStatus = .draft
    public private(set) var signatures = [Signature]()
    public private(set) var submissionDate: Date?
    public private(set) var processedDate: Date?
    public private(set) var transactionHash: TransactionHash?
    public let walletID: WalletID
    public let accountID: AccountID

    // MARK: - Creating Transaction

    public init(id: TransactionID, type: TransactionType, walletID: WalletID, accountID: AccountID) {
        self.type = type
        self.walletID = walletID
        self.accountID = accountID
        super.init(id: id)
    }

    // MARK: - Changing transaction's status

    private static let statusTransitionTable: [TransactionStatus: [TransactionStatus]] =
    [
        .draft: [.signing, .discarded],
        .signing: [.draft, .rejected, .pending, .discarded],
        .rejected: [.discarded],
        .pending: [.success, .failed, .discarded],
        .success: [.discarded],
        .failed: [.discarded],
        .discarded: [.draft]
    ]

    @discardableResult
    public func change(status: TransactionStatus) -> Transaction {
        assertAllowedTransition(to: status)
        if status == .signing {
            try! assertNotNil(sender, Error.senderNotSet)
            try! assertNotNil(recipient, Error.recipientNotSet)
            try! assertNotNil(amount, Error.amountNotSet)
            try! assertNotNil(fee, Error.feeNotSet)
        } else if status == .pending {
            try! assertNotNil(transactionHash, Error.transactionHashNotSet)
        }
        if self.status == .discarded && status == .draft {
            transactionHash = nil
            submissionDate = nil
            processedDate = nil
            signatures = []
        }
        self.status = status
        return self
    }

    private func assertAllowedTransition(to status: TransactionStatus) {
        let allowedNextStates = Transaction.statusTransitionTable[self.status]!
        try! assertTrue(allowedNextStates.contains(status),
                        Error.invalidStatusTransition(from: self.status, to: status))
    }

    // MARK: - Editing Transaction draft

    @discardableResult
    public func change(amount: TokenAmount) -> Transaction {
        assertInDraftStatus()
        self.amount = amount
        return self
    }

    @discardableResult
    public func change(sender: BlockchainAddress) -> Transaction {
        assertInDraftStatus()
        self.sender = sender
        return self
    }

    @discardableResult
    public func change(recipient: BlockchainAddress) -> Transaction {
        assertInDraftStatus()
        self.recipient = recipient
        return self
    }

    @discardableResult
    public func change(fee: TokenAmount) -> Transaction {
        assertInDraftStatus()
        self.fee = fee
        return self
    }

    private func assertInDraftStatus() {
        try! assertEqual(status, .draft, Error.invalidStatusForEditing(status))
    }

    /// Sets hash of the transaction (retrieved from a blockchain or pre-calculated).
    ///
    /// - Parameter hash: hash of the transaction
    @discardableResult
    public func set(hash: TransactionHash) -> Transaction {
        try! assertTrue(status == .draft ||
            status == .signing, Error.invalidStatusForSetHash(status))
        transactionHash = hash
        return self
    }

    // MARK: - Signing Transaction

    @discardableResult
    public func add(signature: Signature) -> Transaction {
        assertSignaturesEditable()
        guard !signatures.contains(signature) else { return self }
        signatures.append(signature)
        return self
    }

    @discardableResult
    public func remove(signature: Signature) -> Transaction {
        assertSignaturesEditable()
        guard let index = signatures.index(of: signature) else { return self }
        signatures.remove(at: index)
        return self
    }

    private func assertSignaturesEditable() {
        try! assertTrue(status == .draft || status == .signing, Error.invalidStatusForSigning(status))
    }

    // MARK: - Recording transaction's state in the blockchain

    /// Records date of submission to a blockchain
    ///
    /// - Parameter at: timestamp of submission event
    @discardableResult
    public func timestampSubmitted(at date: Date) -> Transaction {
        assertCanTimestamp()
        submissionDate = date
        return self
    }

    /// Records date of transaction processing - whether it is failure or success
    ///
    /// - Parameter at: timestamp of transaction processing
    @discardableResult
    public func timestampProcessed(at date: Date) -> Transaction {
        assertCanTimestamp()
        processedDate = date
        return self
    }

    private static let timestampingStatuses: [TransactionStatus] =
        [.draft, .signing, .pending, .rejected, .failed, .success]

    private func assertCanTimestamp() {
        try! assertTrue(Transaction.timestampingStatuses.contains(status),
                       Error.invalidStatusForTimestamp(status))
    }

}

// MARK: - Supporting types

public enum TransactionStatus: Int {

    /// Draft transaction is allowed to change any data
    case draft
    /// Sigining transaction freezes amount, fees, sender and recipient while still allowing to add signatures
    case signing
    /// Pending transaction is the one submitted to a blockchain. At this stage, transaction parameters are immutable.
    /// Pending transaction is allowed to set hash, if it wasn't set before.
    case pending
    /// Transaction is rejected by owner (s) and may not be submitted to blockchain.
    case rejected
    /// Transaction may become failed when it is rejected by blockchain.
    case failed
    /// Transaction is successful when it is processed and added to the blockchain
    case success
    /// Discarded transaction should not be shown to the user, but it is still present in the transactions list.
    /// Transaction may become discarded from any other status when user decides to archive the transaction.
    case discarded

}

public enum TransactionType: Int {

    case transfer

}

// TODO: confusion with EthSignature
public struct Signature: Equatable { // signature of some owner?

    public var address: BlockchainAddress
    public var data: Data

    public init(data: Data, address: BlockchainAddress) {
        self.data = data
        self.address = address
    }

}

public struct TransactionHash: Equatable {

    public let value: String

    public init(_ value: String) {
        self.value = value
    }

}

public struct TransactionReceipt: Equatable {

    public let hash: TransactionHash
    public let status: TransactionStatus

    public init(hash: TransactionHash, status: TransactionStatus) {
        self.hash = hash
        self.status = status
    }
}
