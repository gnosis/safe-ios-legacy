//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class TransactionID: BaseID {}

/// Transaction represents an operation in an account of a wallet.
public class Transaction: IdentifiableEntity<TransactionID> {

    // MARK: - Querying transaction data

    public let type: TransactionType
    public private(set) var sender: BlockchainAddress?
    public private(set) var recipient: BlockchainAddress?
    public private(set) var amount: Money?
    public private(set) var fee: Money?
    public private(set) var status: TransactionStatus = .draft
    public private(set) var signatures = [Signature]()
    public private(set) var submissionDate: Date?
    public private(set) var processedDate: Date?
    public let walletID: WalletID
    public let accountID: AccountID

    // MARK: - Creating Transaction

    init(id: TransactionID, type: TransactionType, walletID: WalletID, accountID: AccountID) {
        self.type = type
        self.walletID = walletID
        self.accountID = accountID
        super.init(id: id)
    }

    // MARK: - Changing transaction's status

    public func change(status: TransactionStatus) {}

    // MARK: - Editing Transaction draft

    public func change(amount: Money) {}
    public func change(sender: BlockchainAddress) {}
    public func change(recipient: BlockchainAddress) {}
    public func change(fee: Money) {}

    // MARK: - Signing Transaction

    /// Moves transaction to `signing` status to collect signatures
    public func lockForSigning() {}

    /// Moves transaction from `signing` status back to `draft` that allows editing
    public func unlockForEditing() {}

    public func add(signature: Signature) {}

    // MARK: - Recording transaction's state in the blockchain

    /// Records date of submission to a blockchain
    ///
    /// - Parameter at: timestamp of submission event
    public func timestampSubmitted(at: Date) {}

    /// Sets hash of the transaction (retrieved from a blockchain submission).
    /// This is a one-time operation and cannot be undone. Supposed to be called within pending `status`.
    ///
    /// - Parameter hash: hash of the transaction
    public func set(hash: TransactionHash) {}

    /// Records date of transaction processing - whether it is failure or success
    ///
    /// - Parameter at: timestamp of transaction processing
    public func timestampProcessed(at: Date) {}

}

// MARK: - Supporting types

public enum TransactionStatus {

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

public enum TransactionType {

    case transfer

}

public struct Signature {

    public var address: BlockchainAddress
    public var data: Data

    public init(data: Data, address: BlockchainAddress) {
        self.data = data
        self.address = address
    }

}

public struct TransactionHash {

    public let value: String

    public init(_ value: String) {
        self.value = value
    }

}
