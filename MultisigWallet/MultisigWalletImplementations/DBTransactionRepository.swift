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
    created_date TEXT,
    updated_date TEXT,
    rejected_date TEXT,
    submission_date TEXT,
    processed_date TEXT,
    transaction_hash TEXT,
    fee_estimate_gas INTEGER,
    fee_estimate_data_gas INTEGER,
    fee_estimate_signature_gas INTEGER,
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
    ?, ?, ?, ?
);
"""
        static let delete = "DELETE FROM tbl_transactions WHERE id = ?;"

        static let fieldList = """
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
    created_date,
    updated_date,
    rejected_date,
    submission_date,
    processed_date,
    transaction_hash,
    fee_estimate_gas,
    fee_estimate_data_gas,
    fee_estimate_signature_gas,
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
LIMIT 1;
"""

        static let findByHashStatus = """
SELECT \(fieldList)
FROM tbl_transactions
WHERE hash = ? AND transaction_status = ?
LIMIT 1;
"""
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
                transaction.walletID.id,
                transaction.accountID.id,
                transaction.type.rawValue,
                transaction.status.rawValue,
                transaction.sender?.value,
                transaction.recipient?.value,
                transaction.amount?.description,
                transaction.fee?.description,
                serialized(signatures: transaction.signatures),
                serialized(date: transaction.createdDate),
                serialized(date: transaction.updatedDate),
                serialized(date: transaction.rejectedDate),
                serialized(date: transaction.submittedDate),
                serialized(date: transaction.processedDate),
                transaction.transactionHash?.value,
                transaction.feeEstimate?.gas,
                transaction.feeEstimate?.dataGas,
                transaction.feeEstimate?.signatureGas,
                transaction.feeEstimate?.gasPrice.description,
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

    public func findByID(_ transactionID: TransactionID) -> Transaction? {
        return try! db.execute(sql: SQL.findByID,
                               bindings: [transactionID.id],
                               resultMap: transactionFromResultSet).first as? Transaction
    }

    public func findBy(hash: Data, status: TransactionStatus) -> Transaction? {
        return try! db.execute(sql: SQL.findByHashStatus,
                               bindings: [hash, status.rawValue],
                               resultMap: transactionFromResultSet).first as? Transaction
    }

    public func findAll() -> [Transaction] {
        return try! db.execute(sql: SQL.findAll, resultMap: transactionFromResultSet).compactMap { $0 }
    }

    private func transactionFromResultSet(_ rs: ResultSet) -> Transaction? {
        let it = rs.rowIterator()
        let (idOrNil, walletIDOrNil, accountIDOrNil, rawTransactionTypeOrNil, rawTransactionStatusOrNil) =
            (it.nextString(), it.nextString(), it.nextString(), it.nextInt(), it.nextInt())
        guard let id = idOrNil,
            let walletID = walletIDOrNil,
            let accountID = accountIDOrNil,
            let rawTransactionType = rawTransactionTypeOrNil,
            let transactionType = TransactionType(rawValue: rawTransactionType),
            let rawTransactionStatus = rawTransactionStatusOrNil,
            let targetTransactionStatus = TransactionStatus(rawValue: rawTransactionStatus) else {
                return nil
        }
        let transaction = Transaction(id: TransactionID(id),
                                      type: transactionType,
                                      walletID: WalletID(walletID),
                                      accountID: AccountID(accountID))
        update(it, transaction)
        // initial status is draft
        switch targetTransactionStatus {
        case .draft: break
        case .signing:
            transaction.change(status: .signing)
        case .pending:
            transaction.change(status: .signing).change(status: .pending)
        case .rejected:
            transaction.change(status: .signing).change(status: .rejected)
        case .failed:
            transaction.change(status: .signing).change(status: .pending).change(status: .failed)
        case .success:
            transaction.change(status: .signing).change(status: .pending).change(status: .success)
        case .discarded:
            transaction.change(status: .discarded)
        }

        return transaction
    }

    private func update(_ it: ResultSetRowIterator, _ transaction: Transaction) {
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

        updateTimestamps(it, transaction)

        if let transactionHashString = it.nextString() {
            transaction.set(hash: TransactionHash(transactionHashString))
        }

        updateRemaining(it, transaction)
    }

    private func updateTimestamps(_ it: ResultSetRowIterator, _ transaction: Transaction) {
        if let date = deserializedDate(it.nextString()) {
            transaction.timestampCreated(at: date)
        }

        if let date = deserializedDate(it.nextString()) {
            transaction.timestampUpdated(at: date)
        }

        if let date = deserializedDate(it.nextString()) {
            transaction.timestampRejected(at: date)
        }

        if let date = deserializedDate(it.nextString()) {
            transaction.timestampSubmitted(at: date)
        }

        if let date = deserializedDate(it.nextString()) {
            transaction.timestampProcessed(at: date)
        }
    }

    private func updateRemaining(_ it: ResultSetRowIterator, _ transaction: Transaction) {
        let (gasOrNil, dataGasOrNil, signatureGasOrNil, gasPriceStringOrNil) =
            (it.nextInt(), it.nextInt(), it.nextInt(), it.nextString())
        if let gas = gasOrNil,
            let dataGas = dataGasOrNil,
            let signatureGas = signatureGasOrNil,
            let gasPriceString = gasPriceStringOrNil,
            let gasPrice = TokenAmount(gasPriceString) {
            transaction.change(feeEstimate: TransactionFeeEstimate(gas: gas,
                                                                   dataGas: dataGas,
                                                                   signatureGas: signatureGas,
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
