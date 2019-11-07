//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import Database
import CommonImplementations

class M0009_MigrateSafesNamesToAddressBookTests: XCTestCase {

    var db: SQLiteDatabase!

    override func setUp() {
        super.setUp()
        db = SQLiteDatabase(name: String(reflecting: self),
                            fileManager: FileManager.default,
                            sqlite: CSQLite3(),
                            bundleId: String(reflecting: self))
        try? db.destroy()
        try! db.create()
    }

    override func tearDown() {
        super.tearDown()
        try? db.destroy()
    }

    // swiftlint:disable function_body_length
    func test_migration() throws {
        // Setting up schema of tables used in migration

        let oldWalletsTable = TableSchema("tbl_wallets",
                                          "id TEXT NOT NULL PRIMARY KEY",
                                          "state INTEGER NOT NULL",
                                          "owners TEXT NOT NULL",
                                          "address TEXT",
                                          "minimum_deployment_tx_amount TEXT",
                                          "creation_tx_hash TEXT",
                                          "confirmation_count INTEGER NOT NULL",
                                          "fee_payment_token_address TEXT",
                                          "master_copy_address TEXT",
                                          "contract_version TEXT",
                                          "name TEXT")
        try db.execute(sql: oldWalletsTable.createTableSQL)

         let addressBookTable = TableSchema("tbl_address_book",
                                            "id TEXT NOT NULL PRIMARY KEY",
                                            "name TEXT NOT NULL",
                                            "address TEXT NOT NULL",
                                            "type INTEGER NOT NULL")
        try db.execute(sql: addressBookTable.createTableSQL)

        // Setting up test data

        // both address and name exist
        try db.execute(sql: oldWalletsTable.insertSQL, bindings: [
            "id1", 0, "owners", "address", "amount", "txhash", 0, "feeaddress", "mastercopy", "contract", "name"
        ])
        // only address exists, name is nil
        try db.execute(sql: oldWalletsTable.insertSQL, bindings: [
            "id2", 0, "owners", "address", "amount", "txhash", 0, "feeaddress", "mastercopy", "contract", nil
        ])
        // only name exists, address is nil
        try db.execute(sql: oldWalletsTable.insertSQL, bindings: [
            "id3", 0, "owners", nil, "amount", "txhash", 0, "feeaddress", "mastercopy", "contract", "name"
        ])
        // both address and name are nils
        try db.execute(sql: oldWalletsTable.insertSQL, bindings: [
            "id4", 0, "owners", nil, "amount", "txhash", 0, "feeaddress", "mastercopy", "contract", nil
        ])

        // Check we have valid data in the database
        let actualEntries = try allEntries(of: oldWalletsTable)
        let expectedEntries: [[String]] = [
            ["id1", "0", "owners", "address", "amount", "txhash", "0", "feeaddress", "mastercopy", "contract", "name"],
            ["id2", "0", "owners", "address", "amount", "txhash", "0", "feeaddress", "mastercopy", "contract", "<nil>"],
            ["id3", "0", "owners", "<nil>", "amount", "txhash", "0", "feeaddress", "mastercopy", "contract", "name"],
            ["id4", "0", "owners", "<nil>", "amount", "txhash", "0", "feeaddress", "mastercopy", "contract", "<nil>"]
        ]
        XCTAssertEqual(actualEntries, expectedEntries)

        // Migrate
        let migration = M0009_MigrateSafesNamesToAddressBook()
        let migrationRepository = DBMigrationRepository(db: db)
        migrationRepository.setUp()
        let migrationService = DBMigrationService(repository: migrationRepository)
        migrationService.register(migration)
        try migrationService.migrate()

        // Check that wallets has migrated correctly
        var newWalletsTable = migration.newWalletsTable
        newWalletsTable.tableName = "tbl_wallets"
        let newWalletActualEntries = try allEntries(of: newWalletsTable)
        let newWalletExpectedEntries: [[String]] = [
            ["id1", "0", "owners", "address", "amount", "txhash", "0", "feeaddress", "mastercopy", "contract"],
            ["id2", "0", "owners", "address", "amount", "txhash", "0", "feeaddress", "mastercopy", "contract"],
            ["id3", "0", "owners", "<nil>", "amount", "txhash", "0", "feeaddress", "mastercopy", "contract"],
            ["id4", "0", "owners", "<nil>", "amount", "txhash", "0", "feeaddress", "mastercopy", "contract"]
        ]
        XCTAssertEqual(newWalletActualEntries, newWalletExpectedEntries)

        // Check that addresses have been created correctly
        let addressBookActualEntries = try allEntries(of: addressBookTable)
        let adddressBookExpectedEntries: [[String]] = [
            ["id1", "name", "address", "1"]
        ]
        XCTAssertEqual(addressBookActualEntries, adddressBookExpectedEntries)
    }

    func allEntries(of table: TableSchema) throws -> [[String]] {
        try db.execute(sql: table.findAllSQL) { rs -> [String]? in
            table.fields.map { field -> String in
                rs[field.name] as String? ?? "<nil>"
            }
        }.compactMap { $0 }
    }

}
