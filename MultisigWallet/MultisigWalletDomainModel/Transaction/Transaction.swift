//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Transaction entity identifier
public class TransactionID: BaseID {}

/// Transaction entity represents an operation in an account of a wallet.
public class Transaction: IdentifiableEntity<TransactionID> {

    /// Various errors that may occur during operations on a Transaciton
    ///
    /// - invalidStatusForEditing: transaction is not editable
    /// - invalidStatusForSigning: transaction cannot be signed
    /// - invalidStatusForSetHash: transaction's hash cannot be sent
    /// - invalidStatusForTimestamp: transaction cannot be timestamped
    /// - invalidStatusTransition: transaction can't change status to the specified one
    /// - senderNotSet: transaction sender is missing
    /// - recipientNotSet: transaction recipient is missing
    /// - amountNotSet: transaction amount is missing
    /// - feeNotSet: transaction fee is missing
    /// - transactionHashNotSet: transaction's hash is missing
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
    public private(set) var sender: Address?
    public private(set) var recipient: Address?
    public private(set) var amount: TokenAmount?
    public private(set) var fee: TokenAmount?
    public private(set) var status: TransactionStatus {
        get {
            return state.status
        }
        set {
            state = TransactionState.status(newValue)
        }
    }
    public private(set) var signatures = [Signature]()
    public private(set) var createdDate: Date!
    public private(set) var updatedDate: Date!
    public private(set) var rejectedDate: Date?
    public private(set) var submittedDate: Date?
    public private(set) var processedDate: Date?
    /// Blockchain transaction hash
    public private(set) var transactionHash: TransactionHash?
    /// Wallet-specific transaction hash
    public private(set) var hash: Data?
    public private(set) var feeEstimate: TransactionFeeEstimate?
    public private(set) var data: Data?
    public private(set) var operation: WalletOperation?
    public private(set) var nonce: String?
    public let walletID: WalletID
    public let accountID: AccountID

    private var state: TransactionState

    // MARK: - Creating Transaction

    public init(id: TransactionID, type: TransactionType, walletID: WalletID, accountID: AccountID) {
        self.type = type
        self.walletID = walletID
        self.accountID = accountID
        self.state = DraftTransactionStatus()
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
            createdDate = nil
            updatedDate = nil
            rejectedDate = nil
            submittedDate = nil
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
    public func change(amount: TokenAmount?) -> Transaction {
        assertInDraftStatus()
        self.amount = amount
        return self
    }

    @discardableResult
    public func change(sender: Address?) -> Transaction {
        assertInDraftStatus()
        self.sender = sender
        return self
    }

    @discardableResult
    public func change(recipient: Address?) -> Transaction {
        assertInDraftStatus()
        self.recipient = recipient
        return self
    }

    @discardableResult
    public func change(fee: TokenAmount?) -> Transaction {
        assertInDraftStatus()
        self.fee = fee
        return self
    }

    @discardableResult
    public func change(feeEstimate: TransactionFeeEstimate?) -> Transaction {
        assertInDraftStatus()
        self.feeEstimate = feeEstimate
        return self
    }

    @discardableResult
    public func change(data: Data?) -> Transaction {
        assertInDraftStatus()
        self.data = data
        return self
    }

    @discardableResult
    public func change(operation: WalletOperation?) -> Transaction {
        assertInDraftStatus()
        self.operation = operation
        return self
    }

    @discardableResult
    public func change(nonce: String?) -> Transaction {
        assertInDraftStatus()
        self.nonce = nonce
        return self
    }

    @discardableResult
    public func change(hash: Data?) -> Transaction {
        assertInDraftStatus()
        self.hash = hash
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

    public func isSignedBy(_ address: Address) -> Bool {
        return signatures.contains { $0.address == address }
    }

    private func assertSignaturesEditable() {
        try! assertTrue(status == .draft || status == .signing, Error.invalidStatusForSigning(status))
    }

    // MARK: - Recording transaction's state in the blockchain

    /// Records date of transaction creation date
    ///
    /// - Parameter at: timestamp of transaction creation
    @discardableResult
    public func timestampCreated(at date: Date) -> Transaction {
        assertCanTimestamp()
        createdDate = date
        return self
    }

    /// Records date of changing a transaction
    ///
    /// - Parameter at: timestamp of submission event
    @discardableResult
    public func timestampUpdated(at date: Date) -> Transaction {
        assertCanTimestamp()
        updatedDate = date
        return self
    }

    /// Records date of transaction rejection
    ///
    /// - Parameter at: timestamp of transaction rejection
    @discardableResult
    public func timestampRejected(at date: Date) -> Transaction {
        assertCanTimestamp()
        rejectedDate = date
        return self
    }
    /// Records date of submission to a blockchain
    ///
    /// - Parameter at: timestamp of submission event
    @discardableResult
    public func timestampSubmitted(at date: Date) -> Transaction {
        assertCanTimestamp()
        submittedDate = date
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
        try! assertTrue(Transaction.timestampingStatuses.contains(status), Error.invalidStatusForTimestamp(status))
    }

}

// MARK: - Supporting types

// TODO: move inside TransactionState class
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

public class TransactionState {

    public var status: TransactionStatus { return .draft }

    public static func status(_ code: TransactionStatus) -> TransactionState {
        switch code {
        case .discarded: return DiscardedTransactionStatus()
        case .draft: return DraftTransactionStatus()
        case .failed: return FailedTransactionStatus()
        case .pending: return PendingTransactionStatus()
        case .rejected: return RejectedTransactionStatus()
        case .signing: return SigningTransactionStatus()
        case .success: return SuccessTransactionStatus()
        }
    }

}

class DraftTransactionStatus: TransactionState {
    override var status: TransactionStatus { return .draft }
}

class SigningTransactionStatus: TransactionState {
    override var status: TransactionStatus { return .signing }
}

class PendingTransactionStatus: TransactionState {
    override var status: TransactionStatus { return .pending }
}

class RejectedTransactionStatus: TransactionState {
    override var status: TransactionStatus { return .rejected }
}

class FailedTransactionStatus: TransactionState {
    override var status: TransactionStatus { return .failed }
}

class SuccessTransactionStatus: TransactionState {
    override var status: TransactionStatus { return .success }
}

class DiscardedTransactionStatus: TransactionState {
    override var status: TransactionStatus { return .discarded }
}


public enum TransactionType: Int {

    case transfer

}

/// Owner's signature of the transaction
public struct Signature: Equatable {

    /// Signer's address
    public var address: Address
    public var data: Data

    public init(data: Data, address: Address) {
        self.data = data
        self.address = address
    }

}

/// Ethereum transaction hash
public struct TransactionHash: Equatable {

    /// Number of bytes in a 256-bit transaction hash
    public static let size = 256 / 8
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

}

/// Ethereum transaction receipt
public struct TransactionReceipt: Equatable {

    public let hash: TransactionHash
    public let status: TransactionStatus

    public init(hash: TransactionHash, status: TransactionStatus) {
        self.hash = hash
        self.status = status
    }
}

/// Estimate of transaction fees
public struct TransactionFeeEstimate: Equatable {

    public let gas: Int
    public let dataGas: Int
    public let operationalGas: Int
    public let gasPrice: TokenAmount

    public init(gas: Int, dataGas: Int, operationalGas: Int, gasPrice: TokenAmount) {
        self.gas = gas
        self.dataGas = dataGas
        self.operationalGas = operationalGas
        self.gasPrice = gasPrice
    }

}

public enum WalletOperation: Int, Codable {

    case call
    case delegateCall
    case create

}

public struct TransactionGroup: Equatable {

    public enum GroupType: Int, Equatable {
        case pending
        case processed
    }

    public let type: GroupType
    public let date: Date?
    public var transactions: [Transaction]

    public init(type: GroupType, date: Date?, transactions: [Transaction]) {
        self.type = type
        self.date = date
        self.transactions = transactions
    }

}

public extension Transaction {

    private var isERC20Transfer: Bool {
        return amount != nil && amount!.token.id != Token.Ether.id
    }

    public var ethTo: Address {
        let result = isERC20Transfer ? amount?.token.address : recipient
        return result ?? .zero
    }

    public var ethValue: TokenInt {
        let result = isERC20Transfer ? 0 : amount?.amount
        return result ?? 0
    }

    public var ethData: String {
        return data == nil ? "" : "0x\(data!.toHexString())"
    }

}
