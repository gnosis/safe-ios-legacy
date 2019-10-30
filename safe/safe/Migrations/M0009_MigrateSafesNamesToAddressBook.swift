//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import CommonImplementations

final class M0009_MigrateSafesNamesToAddressBook: Migration {

    convenience init() {
        // DO NOT CHANGE
        self.init("M0009_MigrateSafesNamesToAddressBook")
    }

    override func setUp(connection: Connection) throws {
        try addTypeColumnToAddressBookEntry(connection: connection)
        try createAddressBookEntriesForSafes(connection: connection)
        try deleteNameColumnFromWalletsTable(connection: connection)
    }

    private func addTypeColumnToAddressBookEntry(connection: Connection) throws {
        let addTypeSQL = "ALTER TABLE tbl_address_book ADD type INTEGER DEFAULT 0;"
        try connection.execute(sql: addTypeSQL)
    }

    private func createAddressBookEntriesForSafes(connection: Connection) throws {
        let migrationSQL = "INSERT INTO tbl_address_book SELECT id, name, address, 1 FROM tbl_wallets;"
        try connection.execute(sql: migrationSQL)
    }

    private func deleteNameColumnFromWalletsTable(connection: Connection) throws {
        let newWalletsTable = TableSchema("tbl_wallets_new",
                                          "id TEXT NOT NULL PRIMARY KEY",
                                          "state INTEGER NOT NULL",
                                          "owners TEXT NOT NULL",
                                          "address TEXT",
                                          "minimum_deployment_tx_amount TEXT",
                                          "creation_tx_hash TEXT",
                                          "confirmation_count INTEGER NOT NULL",
                                          "fee_payment_token_address TEXT",
                                          "master_copy_address TEXT",
                                          "contract_version TEXT")
        try deleteColumns(connection: connection, newTableSchema: newWalletsTable, tableName: "tbl_wallets")
    }

}
