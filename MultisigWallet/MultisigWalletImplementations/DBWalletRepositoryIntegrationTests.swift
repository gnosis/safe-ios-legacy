//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class DBWalletRepositoryIntegrationTests: XCTestCase {

    func test_All() throws {
        let db = SQLiteDatabase(name: "DBWalletRepositoryIntegrationTests",
                                fileManager: FileManager.default,
                                sqlite: CSQLite3(),
                                bundleId: "DBWalletRepositoryIntegrationTests")
        try? db.destroy()
        try db.create()
        defer { try? db.destroy() }
        let repo = DBWalletRepository(db: db)
        repo.setUp()
        let owner = Wallet.createOwner(address: "address")
        let wallet = try Wallet(id: repo.nextID(), owner: owner, kind: "kind")
        repo.save(wallet)
        let saved = repo.findByID(wallet.id)
        XCTAssertEqual(saved, wallet)

        repo.remove(wallet)
        XCTAssertNil(repo.findByID(wallet.id))
    }

}
