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
        case invalidStatusForEditing(TransactionStatus.Code)
        case invalidStatusForSigning(TransactionStatus.Code)
        case invalidStatusForSetHash(TransactionStatus.Code)
        case invalidStatusForTimestamp(TransactionStatus.Code)
        case invalidStatusTransition(from: TransactionStatus.Code, to: TransactionStatus.Code)
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
    public private(set) var status: TransactionStatus.Code {
        get {
            return state.status
        }
        set {
            state = TransactionStatus.status(newValue)
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

    private var state: TransactionStatus

    // MARK: - Creating Transaction

    public init(id: TransactionID, type: TransactionType, walletID: WalletID, accountID: AccountID) {
        self.type = type
        self.walletID = walletID
        self.accountID = accountID
        self.state = DraftTransactionStatus()
        super.init(id: id)
        self.timestampCreated(at: Date())
        self.timestampUpdated(at: Date())
    }

    // MARK: - Changing transaction's status

    @discardableResult
    public func discard() -> Transaction {
        state.discard(self)
        return self
    }

    @discardableResult
    public func reset() -> Transaction {
        state.reset(self)
        return self
    }

    internal func resetParameters() {
        transactionHash = nil
        createdDate = nil
        updatedDate = nil
        rejectedDate = nil
        submittedDate = nil
        processedDate = nil
        signatures = []
    }

    @discardableResult
    public func proceed() -> Transaction {
        state.proceed(self)
        return self
    }

    @discardableResult
    public func reject() -> Transaction {
        state.reject(self)
        return self
    }

    @discardableResult
    public func succeed() -> Transaction {
        state.succeed(self)
        return self
    }

    @discardableResult
    public func fail() -> Transaction {
        state.fail(self)
        return self
    }

    @discardableResult
    internal func change(status: TransactionStatus.Code) -> Transaction {
        self.status = status
        return self
    }

    // MARK: - Editing Transaction draft

    @discardableResult
    public func change(amount: TokenAmount?) -> Transaction {
        assertCanChangeParameters()
        self.amount = amount
        timestampUpdated(at: Date())
        return self
    }

    @discardableResult
    public func change(sender: Address?) -> Transaction {
        assertCanChangeParameters()
        self.sender = sender
        timestampUpdated(at: Date())
        return self
    }

    @discardableResult
    public func change(recipient: Address?) -> Transaction {
        assertCanChangeParameters()
        self.recipient = recipient
        timestampUpdated(at: Date())
        return self
    }

    @discardableResult
    public func change(fee: TokenAmount?) -> Transaction {
        assertCanChangeParameters()
        self.fee = fee
        timestampUpdated(at: Date())
        return self
    }

    @discardableResult
    public func change(feeEstimate: TransactionFeeEstimate?) -> Transaction {
        assertCanChangeParameters()
        self.feeEstimate = feeEstimate
        timestampUpdated(at: Date())
        return self
    }

    @discardableResult
    public func change(data: Data?) -> Transaction {
        assertCanChangeParameters()
        self.data = data
        timestampUpdated(at: Date())
        return self
    }

    @discardableResult
    public func change(operation: WalletOperation?) -> Transaction {
        assertCanChangeParameters()
        self.operation = operation
        timestampUpdated(at: Date())
        return self
    }

    @discardableResult
    public func change(nonce: String?) -> Transaction {
        assertCanChangeParameters()
        self.nonce = nonce
        timestampUpdated(at: Date())
        return self
    }

    @discardableResult
    public func change(hash: Data?) -> Transaction {
        assertCanChangeParameters()
        self.hash = hash
        timestampUpdated(at: Date())
        return self
    }

    private func assertCanChangeParameters() {
        try! assertTrue(state.canChangeParameters, Error.invalidStatusForEditing(status))
    }

    /// Sets hash of the transaction (retrieved from a blockchain or pre-calculated).
    ///
    /// - Parameter hash: hash of the transaction
    @discardableResult
    public func set(hash: TransactionHash) -> Transaction {
        try! assertTrue(state.canChangeBlockchainHash, Error.invalidStatusForSetHash(status))
        transactionHash = hash
        timestampUpdated(at: Date())
        return self
    }

    // MARK: - Signing Transaction

    @discardableResult
    public func add(signature: Signature) -> Transaction {
        assertSignaturesEditable()
        guard !signatures.contains(signature) else { return self }
        signatures.append(signature)
        timestampUpdated(at: Date())
        return self
    }

    @discardableResult
    public func remove(signature: Signature) -> Transaction {
        assertSignaturesEditable()
        guard let index = signatures.index(of: signature) else { return self }
        signatures.remove(at: index)
        timestampUpdated(at: Date())
        return self
    }

    public func isSignedBy(_ address: Address) -> Bool {
        return signatures.contains { $0.address == address }
    }

    private func assertSignaturesEditable() {
        try! assertTrue(state.canChangeSignatures, Error.invalidStatusForSigning(status))
    }

    // MARK: - Recording transaction's state in the blockchain

    /// Records date of transaction creation date
    ///
    /// - Parameter at: timestamp of transaction creation
    @discardableResult
    public func timestampCreated(at date: Date) -> Transaction {
        createdDate = date
        return self
    }

    /// Records date of changing a transaction
    ///
    /// - Parameter at: timestamp of submission event
    @discardableResult
    public func timestampUpdated(at date: Date) -> Transaction {
        updatedDate = date
        return self
    }

    /// Records date of transaction rejection
    ///
    /// - Parameter at: timestamp of transaction rejection
    @discardableResult
    public func timestampRejected(at date: Date) -> Transaction {
        rejectedDate = date
        return self
    }
    /// Records date of submission to a blockchain
    ///
    /// - Parameter at: timestamp of submission event
    @discardableResult
    public func timestampSubmitted(at date: Date) -> Transaction {
        submittedDate = date
        return self
    }

    /// Records date of transaction processing - whether it is failure or success
    ///
    /// - Parameter at: timestamp of transaction processing
    @discardableResult
    public func timestampProcessed(at date: Date) -> Transaction {
        processedDate = date
        return self
    }

}

// MARK: - Supporting types

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
    public let status: TransactionStatus.Code

    public init(hash: TransactionHash, status: TransactionStatus.Code) {
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
