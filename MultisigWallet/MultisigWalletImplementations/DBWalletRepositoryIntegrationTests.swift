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
        try repo.setUp()
        let owner = Wallet.createOwner(address: "address")
        let wallet = try Wallet(id: repo.nextID(), owner: owner, kind: "kind")
        try repo.save(wallet)
        let saved = try repo.findByID(wallet.id)
        XCTAssertEqual(saved, wallet)

        try repo.remove(wallet)
        XCTAssertNil(try repo.findByID(wallet.id))
    }

}
