//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import CommonImplementations

final class M0006_RemoveWalletIDFromTransactions: Migration {

    let oldTable = TableSchema("tbl_transactions",
                               "id TEXT NOT NULL PRIMARY KEY",
                               "wallet_id TEXT NOT NULL", // to be removed
                               "account_id TEXT NOT NULL",
                               "transaction_type INTEGER NOT NULL",
                               "transaction_status INTEGER NOT NULL",
                               "sender TEXT",
                               "recipient TEXT",
                               "amount TEXT",
                               "fee TEXT",
                               "signatures TEXT",
                               "created_date TEXT",
                               "updated_date TEXT",
                               "rejected_date TEXT",
                               "submission_date TEXT",
                               "processed_date TEXT",
                               "transaction_hash TEXT",
                               "fee_estimate_gas TEXT",
                               "fee_estimate_data_gas TEXT",
                               "fee_estimate_operational_gas TEXT",
                               "fee_estimate_gas_price TEXT",
                               "data BLOB",
                               "operation INTEGER",
                               "nonce TEXT",
                               "hash BLOB")

    let newTable = TableSchema("new_tbl_transactions",
                               "id TEXT NOT NULL PRIMARY KEY",
                               "account_id TEXT NOT NULL",
                               "transaction_type INTEGER NOT NULL",
                               "transaction_status INTEGER NOT NULL",
                               "sender TEXT",
                               "recipient TEXT",
                               "amount TEXT",
                               "fee TEXT",
                               "signatures TEXT",
                               "created_date TEXT",
                               "updated_date TEXT",
                               "rejected_date TEXT",
                               "submission_date TEXT",
                               "processed_date TEXT",
                               "transaction_hash TEXT",
                               "fee_estimate_gas TEXT",
                               "fee_estimate_data_gas TEXT",
                               "fee_estimate_operational_gas TEXT",
                               "fee_estimate_gas_price TEXT",
                               "data BLOB",
                               "operation INTEGER",
                               "nonce TEXT",
                               "hash BLOB")

    convenience init() {
        // DO NOT CHANGE
        self.init("M0006_RemoveWalletIDFromTransactions")
    }

    override func setUp(connection: Connection) throws {
        try connection.execute(sql: newTable.createTableSQL)
        try connection.execute(sql: "INSERT INTO \(newTable.tableName) " +
            "SELECT \(newTable.fieldNameList) FROM \(oldTable.tableName);")
        try connection.execute(sql: "DROP TABLE \(oldTable.tableName);")
        try connection.execute(sql: "ALTER TABLE \(newTable.tableName) RENAME TO \(oldTable.tableName);")
    }

}
