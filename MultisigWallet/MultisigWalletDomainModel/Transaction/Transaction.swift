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

    public private(set) var type: TransactionType
    public private(set) var sender: Address?
    public private(set) var recipient: Address?
    public private(set) var amount: TokenAmount?
    public private(set) var fee: TokenAmount?
    public private(set) var status: TransactionStatus.Code {
        get {
            return state.code
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
    public let accountID: AccountID

    private var state: TransactionStatus

    // MARK: - Creating Transaction

    public init(id: TransactionID, type: TransactionType, accountID: AccountID) {
        self.type = type
        self.accountID = accountID
        self.state = DraftTransactionStatus()
        super.init(id: id)
        self.timestampCreated(at: Date())
        self.timestampUpdated(at: Date())
    }

    // MARK: - Validating transaction

    public func isDangerous(walletAddress: Address) -> Bool {
        return ![nil, .call].contains(operation) ||
            (recipient == walletAddress && !(data?.isEmpty ?? true))
    }

    // MARK: - Changing transaction's status

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
    public func stepBack() -> Transaction {
        state.stepBack(self)
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

    @discardableResult
    public func change(type: TransactionType) -> Transaction {
        assertCanChangeParameters()
        self.type = type
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
        guard let index = signatures.firstIndex(of: signature) else { return self }
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

// NOTE: If you change old enum values, then you'll need to run DB migration.
// Adding new ones is OK as long as you don't change old values.
public enum TransactionType: Int {

    case transfer = 0
    case walletRecovery = 1
    case replaceRecoveryPhrase = 2
    case replaceTwoFAWithAuthenticator = 3
    case connectAuthenticator = 4
    case disconnectAuthenticator = 5
    case contractUpgrade = 6
    case replaceTwoFAWithStatusKeycard = 7
    case connectStatusKeycard = 8
    case disconnectStatusKeycard = 9

}

extension TransactionType {

    var correspondingOwnerRole: OwnerRole? {
        switch self {
        case .replaceTwoFAWithAuthenticator,
             .connectAuthenticator,
             .disconnectAuthenticator:
            return .browserExtension
        case .replaceTwoFAWithStatusKeycard,
             .connectStatusKeycard,
             .disconnectStatusKeycard:
            return .keycard
        default:
            return nil
        }
    }

    public var isConnectTwoFA: Bool {
        return self == .connectStatusKeycard || self == .connectAuthenticator
    }

    public var isDisconnectTwoFA: Bool {
        return self == .disconnectStatusKeycard || self == .disconnectAuthenticator
    }

    public var isReplaceTwoFA: Bool {
        return self == .replaceTwoFAWithAuthenticator || self == .replaceTwoFAWithStatusKeycard
    }

    public var isReplaceOrDisconnectTwoFA: Bool {
        return isReplaceTwoFA || isDisconnectTwoFA
    }

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
    public let blockHash: String

    public init(hash: TransactionHash, status: TransactionStatus.Code, blockHash: String) {
        self.hash = hash
        self.status = status
        self.blockHash = blockHash
    }
}

/// Ethereum block
public struct EthBlock: Equatable {

    public let hash: String
    public let timestamp: Date

    public init(hash: String, timestamp: Date) {
        self.hash = hash
        self.timestamp = timestamp
    }

}

/// Estimate of transaction fees
public struct TransactionFeeEstimate: Equatable {

    public let gas: TokenInt
    public let dataGas: TokenInt
    public let operationalGas: TokenInt
    public let gasPrice: TokenAmount

    public init(gas: TokenInt, dataGas: TokenInt, operationalGas: TokenInt, gasPrice: TokenAmount) {
        self.gas = gas
        self.dataGas = dataGas
        self.operationalGas = operationalGas
        self.gasPrice = gasPrice
    }

    /// The value displayed to user includes operationalGas parameter.
    public var totalDisplayedToUser: TokenAmount {
        return TokenAmount(amount: gasPrice.amount * (gas + dataGas + operationalGas),
                           token: gasPrice.token)
    }

    /// The value submitted to blockchain does not include operational gas parameter.
    public var totalSubmittedToBlockchain: TokenAmount {
        return TokenAmount(amount: gasPrice.amount * (gas + dataGas),
                           token: gasPrice.token)
    }

}

// NOTE: If you change enum values, then you'll need to run DB migration.
// Adding new ones is OK as long as you don't change old values
public enum WalletOperation: Int, Codable {

    case call = 0
    case delegateCall = 1
    case create = 2

}

public struct TransactionGroup: Equatable {

    public enum GroupType: Int, Equatable {
        case pending = 0
        case processed = 1
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

    var ethTo: Address {
        let result = isERC20Transfer ? amount?.token.address : recipient
        return result ?? .zero
    }

    var ethValue: TokenInt {
        let result = isERC20Transfer ? 0 : amount?.amount
        return result ?? 0
    }

    var ethData: String {
        return data == nil ? "" : "0x\(data!.toHexString())"
    }

}
