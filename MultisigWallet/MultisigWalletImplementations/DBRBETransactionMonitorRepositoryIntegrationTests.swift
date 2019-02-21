//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class DBRBETransactionMonitorRepositoryIntegrationTests: XCTestCase {

    func test_all() throws {
        let db = SQLiteDatabase(name: String(reflecting: self),
                                fileManager: FileManager.default,
                                sqlite: CSQLite3(),
                                bundleId: String(reflecting: self))
        try? db.destroy()
        try db.create()
        defer { try? db.destroy() }

        let repo = DBRBETransactionMonitorRepository(db: db)
        repo.setUp()

        let entry = RBETransactionMonitorEntry(transactionID: TransactionID("some"), createdDate: Date())

        repo.save(entry)
        let saved = repo.find(id: entry.transactionID)
        XCTAssertEqual(saved, entry)

        let all = repo.findAll()
        XCTAssertEqual(all, [entry])

        repo.remove(entry)
        XCTAssertNil(repo.find(id: entry.transactionID))
        XCTAssertTrue(repo.findAll().isEmpty)
    }

}
