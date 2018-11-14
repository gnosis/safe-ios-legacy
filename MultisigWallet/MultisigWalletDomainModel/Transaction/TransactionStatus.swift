//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class TransactionStatus: Assertable {

    public enum Code: Int {
        /// Draft transaction is allowed to change any data
        case draft
        /// Sigining transaction freezes amount, fees, sender and recipient while still allowing to add signatures
        case signing
        /// Pending transaction is the one submitted to a blockchain. Transaction parameters are immutable.
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

    var code: TransactionStatus.Code { return .draft }
    var canChangeParameters: Bool { return false }
    var canChangeBlockchainHash: Bool { return false }
    var canChangeSignatures: Bool { return false }

    static func status(_ code: TransactionStatus.Code) -> TransactionStatus {
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

    func discard(_ tx: Transaction) {
        tx.timestampUpdated(at: Date()).change(status: .discarded)

    }

    func reset(_ tx: Transaction) {
        preconditionFailure("Illegal state transition: reset transaction from \(code)")
    }

    func reject(_ tx: Transaction) {
        preconditionFailure("Illegal state transition: reject transaction from \(code)")
    }

    func succeed(_ tx: Transaction) {
        preconditionFailure("Illegal state transition: succeed transaction from \(code)")
    }

    func fail(_ tx: Transaction) {
        preconditionFailure("Illegal state transition: fail transaction from \(code)")
    }

    func proceed(_ tx: Transaction) {
        preconditionFailure("Illegal state transition: proceed transaction from \(code)")
    }

}

class DraftTransactionStatus: TransactionStatus {

    override var code: TransactionStatus.Code { return .draft }
    override var canChangeParameters: Bool { return true }
    override var canChangeBlockchainHash: Bool { return true }
    override var canChangeSignatures: Bool { return true }

    override func proceed(_ tx: Transaction) {
        try! assertNotNil(tx.sender, Transaction.Error.senderNotSet)
        try! assertNotNil(tx.recipient, Transaction.Error.recipientNotSet)
        try! assertNotNil(tx.amount, Transaction.Error.amountNotSet)
        try! assertNotNil(tx.fee, Transaction.Error.feeNotSet)
        tx.change(status: .signing)
            .timestampUpdated(at: Date())
    }

}

class SigningTransactionStatus: TransactionStatus {

    override var code: TransactionStatus.Code { return .signing }
    override var canChangeBlockchainHash: Bool { return true }
    override var canChangeSignatures: Bool { return true }

    override func proceed(_ tx: Transaction) {
        try! assertNotNil(tx.transactionHash, Transaction.Error.transactionHashNotSet)
        tx.change(status: .pending)
            .timestampSubmitted(at: Date())
            .timestampUpdated(at: Date())
    }

    override func reject(_ tx: Transaction) {
        tx.change(status: .rejected)
            .timestampRejected(at: Date())
            .timestampUpdated(at: Date())
    }

}

class PendingTransactionStatus: TransactionStatus {

    override var code: TransactionStatus.Code { return .pending }
    override func succeed(_ tx: Transaction) {
        tx.change(status: .success)
            .timestampProcessed(at: Date())
            .timestampUpdated(at: Date())
    }

    override func fail(_ tx: Transaction) {
        tx.change(status: .failed)
            .timestampProcessed(at: Date())
            .timestampUpdated(at: Date())
    }

}

class RejectedTransactionStatus: TransactionStatus {
    override var code: TransactionStatus.Code { return .rejected }
}

class FailedTransactionStatus: TransactionStatus {
    override var code: TransactionStatus.Code { return .failed }
}

class SuccessTransactionStatus: TransactionStatus {
    override var code: TransactionStatus.Code { return .success }
}

class DiscardedTransactionStatus: TransactionStatus {

    override var code: TransactionStatus.Code { return .discarded }

    override func discard(_ tx: Transaction) {
        preconditionFailure("Illegal state transition: discard transaction from \(code)")
    }

    public override func reset(_ tx: Transaction) {
        tx.resetParameters()
        tx.change(status: .draft)
    }
}
