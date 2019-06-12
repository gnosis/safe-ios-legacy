//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import CommonImplementations

final class M0005_ChangeTransactionFeeColumnType: Migration {

    let oldTable = TableSchema("tbl_transactions",
                               "id TEXT NOT NULL PRIMARY KEY",
                               "wallet_id TEXT NOT NULL",
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
                               "fee_estimate_gas INTEGER",
                               "fee_estimate_data_gas INTEGER",
                               "fee_estimate_operational_gas INTEGER",
                               "fee_estimate_gas_price TEXT",
                               "data BLOB",
                               "operation INTEGER",
                               "nonce TEXT",
                               "hash BLOB")

    let newTable = TableSchema("new_tbl_transactions",
                               "id TEXT NOT NULL PRIMARY KEY",
                               "wallet_id TEXT NOT NULL",
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
                               "fee_estimate_gas TEXT", // changed type
                               "fee_estimate_data_gas TEXT", // changed type
                               "fee_estimate_operational_gas TEXT", // changed type
                               "fee_estimate_gas_price TEXT",
                               "data BLOB",
                               "operation INTEGER",
                               "nonce TEXT",
                               "hash BLOB")

    convenience init() {
        // DO NOT CHANGE
        self.init("M0005_ChangeTransactionFeeColumnType")
    }

    override func setUp(connection: Connection) throws {
        try connection.execute(sql: newTable.createTableSQL)
        try connection.execute(sql: "INSERT INTO \(newTable.tableName) " +
                                    "SELECT \(oldTable.fieldNameList) FROM \(oldTable.tableName);")
        try connection.execute(sql: "DROP TABLE \(oldTable.tableName);")
        try connection.execute(sql: "ALTER TABLE \(newTable.tableName) RENAME TO \(oldTable.tableName);")
    }

}
