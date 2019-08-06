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
    account_id TEXT NOT NULL,
    transaction_type INTEGER NOT NULL,
    transaction_status INTEGER NOT NULL,
    sender TEXT,
    recipient TEXT,
    amount TEXT,
    fee TEXT,
    signatures TEXT,
    created_date TEXT,
    updated_date TEXT,
    rejected_date TEXT,
    submission_date TEXT,
    processed_date TEXT,
    transaction_hash TEXT,
    fee_estimate_gas TEXT,
    fee_estimate_data_gas TEXT,
    fee_estimate_operational_gas TEXT,
    fee_estimate_gas_price TEXT,
    data BLOB,
    operation INTEGER,
    nonce TEXT,
    hash BLOB
);
"""
        static let insert = """
INSERT OR REPLACE INTO tbl_transactions VALUES (
    ?, ?, ?, ?,
    ?, ?, ?, ?,
    ?, ?, ?, ?,
    ?, ?, ?, ?,
    ?, ?, ?, ?,
    ?, ?, ?
);
"""
        static let delete = "DELETE FROM tbl_transactions WHERE id = ?;"

        static let fieldList = """
    id,
    account_id,
    transaction_type,
    transaction_status,
    sender,
    recipient,
    amount,
    fee,
    signatures,
    created_date,
    updated_date,
    rejected_date,
    submission_date,
    processed_date,
    transaction_hash,
    fee_estimate_gas,
    fee_estimate_data_gas,
    fee_estimate_operational_gas,
    fee_estimate_gas_price,
    data,
    operation,
    nonce,
    hash
"""

        static let findByID = """
SELECT \(fieldList)
FROM tbl_transactions
WHERE id = ?
ORDER BY rowid
LIMIT 1;
"""

        static let findByHashStatus = """
SELECT \(fieldList)
FROM tbl_transactions
WHERE hash = ? AND transaction_status = ?
ORDER BY datetime(created_date, 'unixepoch') DESC
LIMIT 1;
"""
        static let findByTypeAndWallet = """
        SELECT \(fieldList)
        FROM tbl_transactions
        WHERE transaction_type = ? AND account_id GLOB ?
        ORDER BY rowid
        LIMIT 1;
        """
        static let findByHash = "SELECT \(fieldList) FROM tbl_transactions WHERE hash = ? ORDER BY rowid LIMIT 1;"
        static let findAll = "SELECT \(fieldList) FROM tbl_transactions;"

    }

    private let db: Database

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
                transaction.accountID.id,
                transaction.type.rawValue,
                transaction.status.rawValue,
                transaction.sender?.value,
                transaction.recipient?.value,
                transaction.amount?.serializedStringValue,
                transaction.fee?.serializedStringValue,
                serialized(signatures: transaction.signatures),
                serialized(date: transaction.createdDate),
                serialized(date: transaction.updatedDate),
                serialized(date: transaction.rejectedDate),
                serialized(date: transaction.submittedDate),
                serialized(date: transaction.processedDate),
                transaction.transactionHash?.value,
                transaction.feeEstimate?.gas.serializedValue,
                transaction.feeEstimate?.dataGas.serializedValue,
                transaction.feeEstimate?.operationalGas.serializedValue,
                transaction.feeEstimate?.gasPrice.serializedStringValue,
                transaction.data,
                transaction.operation?.rawValue,
                transaction.nonce,
                transaction.hash
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
            return Signature(data: Data(ethHex: parts.last!), address: Address(parts.first!))
        }
    }

    private func serialized(date: Date?) -> String? {
        guard let date = date else { return nil }
        return String(date.timeIntervalSinceReferenceDate)
    }

    private func deserializedDate(_ string: String?) -> Date? {
        guard let string = string, let interval = TimeInterval(string) else { return nil }
        return Date(timeIntervalSinceReferenceDate: interval)
    }

    public func remove(_ transaction: Transaction) {
        try! db.execute(sql: SQL.delete, bindings: [transaction.id.id])
    }

    public func find(id transactionID: TransactionID) -> Transaction? {
        return try! db.execute(sql: SQL.findByID,
                               bindings: [transactionID.id],
                               resultMap: transactionFromResultSet).first as? Transaction
    }

    public func find(hash: Data, status: TransactionStatus.Code) -> Transaction? {
        return try! db.execute(sql: SQL.findByHashStatus,
                               bindings: [hash, status.rawValue],
                               resultMap: transactionFromResultSet).first as? Transaction
    }

    public func find(hash: Data) -> Transaction? {
        return try! db.execute(sql: SQL.findByHash,
                               bindings: [hash],
                               resultMap: transactionFromResultSet).first as? Transaction
    }

    public func find(type: TransactionType, wallet: WalletID) -> Transaction? {
        return try! db.execute(sql: SQL.findByTypeAndWallet,
                               bindings: [type.rawValue, "*:" + wallet.id],
                               resultMap: transactionFromResultSet).first as? Transaction
    }

    public func all() -> [Transaction] {
        return try! db.execute(sql: SQL.findAll, resultMap: transactionFromResultSet).compactMap { $0 }
    }

    private func transactionFromResultSet(_ rs: ResultSet) -> Transaction? {
        let it = rs.rowIterator()
        let (idOrNil, accountIDOrNil, rawTransactionTypeOrNil, rawTransactionStatusOrNil) =
            (it.nextString(), it.nextString(), it.nextInt(), it.nextInt())
        guard let id = idOrNil,
            let accountID = accountIDOrNil,
            let rawTransactionType = rawTransactionTypeOrNil,
            let transactionType = TransactionType(rawValue: rawTransactionType),
            let rawTransactionStatus = rawTransactionStatusOrNil,
            let targetTransactionStatus = TransactionStatus.Code(rawValue: rawTransactionStatus) else {
                return nil
        }
        let transaction = Transaction(id: TransactionID(id),
                                      type: transactionType,
                                      accountID: AccountID(accountID))
        let timestamps = update(it, transaction)

        // initial status is draft
        switch targetTransactionStatus {
        case .draft: break
        case .signing:
            transaction.proceed()
        case .pending:
            transaction.proceed().proceed()
        case .rejected:
            transaction.proceed().reject()
        case .failed:
            transaction.proceed().proceed().fail()
        case .success:
            transaction.proceed().proceed().succeed()
        }

        // because status changes will modify timestamps
        timestamp(transaction, with: timestamps)

        return transaction
    }

    private func update(_ it: ResultSetRowIterator, _ transaction: Transaction) -> Timestamps {
        if let sender = it.nextString() {
            transaction.change(sender: Address(sender))
        }

        if let recipient = it.nextString() {
            transaction.change(recipient: Address(recipient))
        }

        if let amountString = it.nextString(), let amount = TokenAmount(amountString) {
            transaction.change(amount: amount)
        }

        if let feeString = it.nextString(), let fee = TokenAmount(feeString) {
            transaction.change(fee: fee)
        }

        if let signaturesString = it.nextString() {
            let signatures = deserialized(signatures: signaturesString)
            signatures.forEach { transaction.add(signature: $0) }
        }

        let timestamps = fetchTimestamps(it)

        if let transactionHashString = it.nextString() {
            transaction.set(hash: TransactionHash(transactionHashString))
        }

        updateRemaining(it, transaction)

        return timestamps
    }

    private typealias Timestamps = (created: Date?, updated: Date?, rejected: Date?, submitted: Date?, processed: Date?)

    private func fetchTimestamps(_ it: ResultSetRowIterator) -> Timestamps {
        return (created: deserializedDate(it.nextString()),
                updated: deserializedDate(it.nextString()),
                rejected: deserializedDate(it.nextString()),
                submitted: deserializedDate(it.nextString()),
                processed: deserializedDate(it.nextString()))
    }

    private func timestamp(_ tx: Transaction, with stamps: Timestamps) {
        if let date = stamps.created {
            tx.timestampCreated(at: date)
        }
        if let date = stamps.updated {
            tx.timestampUpdated(at: date)
        }
        if let date = stamps.rejected {
            tx.timestampRejected(at: date)
        }
        if let date = stamps.submitted {
            tx.timestampSubmitted(at: date)
        }
        if let date = stamps.processed {
            tx.timestampProcessed(at: date)
        }
    }

    private func updateRemaining(_ it: ResultSetRowIterator, _ transaction: Transaction) {
        let (gasOrNil, dataGasOrNil, operationalGasOrNil, gasPriceStringOrNil) =
            (it.nextString(), it.nextString(), it.nextString(), it.nextString())
        if let gasString = gasOrNil, let gas = TokenInt(gasString),
            let dataGasString = dataGasOrNil, let dataGas = TokenInt(dataGasString),
            let operationalGasString = operationalGasOrNil, let operationalGas = TokenInt(operationalGasString),
            let gasPriceString = gasPriceStringOrNil, let gasPrice = TokenAmount(gasPriceString) {
            transaction.change(feeEstimate: TransactionFeeEstimate(gas: gas,
                                                                   dataGas: dataGas,
                                                                   operationalGas: operationalGas,
                                                                   gasPrice: gasPrice))
        }

        if let data = it.nextData() {
            transaction.change(data: data)
        }

        if let operationInt = it.nextInt(), let operation = WalletOperation(rawValue: operationInt) {
            transaction.change(operation: operation)
        }

        if let nonce = it.nextString() {
            transaction.change(nonce: nonce)
        }

        if let data = it.nextData() {
            transaction.change(hash: data)
        }
    }

    public func nextID() -> TransactionID {
        return TransactionID()
    }

}
