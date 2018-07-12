//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Database
import CryptoSwift

public class DBTransactionRepository: TransactionRepository {

    struct SQL {
        static let createTable = """
CREATE TABLE IF NOT EXISTS tbl_transactions (
    id TEXT NOT NULL PRIMARY KEY,
    wallet_id TEXT NOT NULL,
    account_id TEXT NOT NULL,
    transaction_type INTEGER NOT NULL,
    transaction_status INTEGER NOT NULL,
    sender TEXT,
    recipient TEXT,
    amount TEXT,
    fee TEXT,
    signatures TEXT,
    submission_date TEXT,
    processed_date TEXT,
    transaction_hash TEXT
);
"""
        static let insert = """
INSERT OR REPLACE INTO tbl_transactions VALUES (
    ?, ?, ?, ?,
    ?, ?, ?, ?,
    ?, ?, ?, ?,
    ?
);
"""
        static let delete = "DELETE FROM tbl_transactions WHERE id = ?;"
        static let findByID = """
SELECT
    id,
    wallet_id,
    account_id,
    transaction_type,
    transaction_status,
    sender,
    recipient,
    amount,
    fee,
    signatures,
    submission_date,
    processed_date,
    transaction_hash
FROM tbl_transactions
WHERE id = ?
LIMIT 1;
"""
    }

    private let db: Database
    private static let dateFormatter = ISO8601DateFormatter()

    public init(db: Database) {
        self.db = db
    }

    public func setUp() {
        try! db.execute(sql: SQL.createTable)
    }

    public func save(_ transaction: Transaction) {
        try! db.execute(sql: SQL.insert, bindings:
            [
                transaction.id.id,
                transaction.walletID.id,
                transaction.accountID.token,
                transaction.type.rawValue,
                transaction.status.rawValue,
                transaction.sender?.value,
                transaction.recipient?.value,
                transaction.amount?.description,
                transaction.fee?.description,
                serialized(signatures: transaction.signatures),
                serialized(date: transaction.submissionDate),
                serialized(date: transaction.processedDate),
                transaction.transactionHash?.value
            ])
    }

    private func serialized(signatures: [Signature]) -> String {
        return signatures.map { "\($0.address.value),\($0.data.toHexString())" }.joined(separator: ";")
    }

    private func deserialized(signatures: String) -> [Signature] {
        let values = signatures.components(separatedBy: ";")
        return values.compactMap { value -> Signature? in
            let parts = value.components(separatedBy: ",")
            guard parts.count == 2 else { return nil }
            return Signature(data: Data(hex: parts.last!), address: BlockchainAddress(value: parts.first!))
        }
    }

    private func serialized(date: Date?) -> String? {
        guard let date = date else { return nil }
        return DBTransactionRepository.dateFormatter.string(from: date)
    }

    public func remove(_ transaction: Transaction) {
        try! db.execute(sql: SQL.delete, bindings: [transaction.id.id])
    }

    public func findByID(_ transactionID: TransactionID) -> Transaction? {
        return try! db.execute(sql: SQL.findByID,
                               bindings: [transactionID.id],
                               resultMap: transactionFromResultSet).first as? Transaction
    }

    //swiftlint:disable cyclomatic_complexity
    private func transactionFromResultSet(_ rs: ResultSet) -> Transaction? {
        guard let id = rs.string(at: 0),
            let walletID = rs.string(at: 1),
            let accountID = rs.string(at: 2),
            let rawTransactionType = rs.int(at: 3),
            let transactionType = TransactionType(rawValue: rawTransactionType),
            let rawTransactionStatus = rs.int(at: 4),
            let targetTransactionStatus = TransactionStatus(rawValue: rawTransactionStatus) else {
                return nil
        }
        let transaction = Transaction(id: TransactionID(id),
                                      type: transactionType,
                                      walletID: WalletID(walletID),
                                      accountID: AccountID(token: accountID))

        if let sender = rs.string(at: 5) {
            try! transaction.change(sender: BlockchainAddress(value: sender))
        }

        if let recipient = rs.string(at: 6) {
            try! transaction.change(recipient: BlockchainAddress(value: recipient))
        }

        if let amountString = rs.string(at: 7), let amount = TokenAmount(amountString) {
            try! transaction.change(amount: amount)
        }

        if let feeString = rs.string(at: 8), let fee = TokenAmount(feeString) {
            try! transaction.change(fee: fee)
        }

        if let signaturesString = rs.string(at: 9) {
            let signatures = deserialized(signatures: signaturesString)
            signatures.forEach { try! transaction.add(signature: $0) }
        }

        if let submissionDateString = rs.string(at: 10),
            let date = DBTransactionRepository.dateFormatter.date(from: submissionDateString) {
            try! transaction.timestampSubmitted(at: date)
        }

        if let processedDateString = rs.string(at: 11),
            let date = DBTransactionRepository.dateFormatter.date(from: processedDateString) {
            try! transaction.timestampProcessed(at: date)
        }

        if let transactionHashString = rs.string(at: 12) {
            try! transaction.set(hash: TransactionHash(transactionHashString))
        }

        // initial status is draft
        switch targetTransactionStatus {
        case .draft: break
        case .signing:
            try! transaction.change(status: .signing)
        case .pending:
            try! transaction.change(status: .signing).change(status: .pending)
        case .rejected:
            try! transaction.change(status: .signing).change(status: .rejected)
        case .failed:
            try! transaction.change(status: .signing).change(status: .pending).change(status: .failed)
        case .success:
            try! transaction.change(status: .signing).change(status: .pending).change(status: .success)
        case .discarded:
            try! transaction.change(status: .discarded)
        }

        return transaction
    }

    public func nextID() -> TransactionID {
        return TransactionID()
    }

}
