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
        let wallet = Wallet(id: repo.nextID(), owner: Address.testAccount1)
        repo.save(wallet)
        let saved = repo.findByID(wallet.id)
        XCTAssertEqual(saved, wallet)

        let wallet2 = Wallet(id: repo.nextID(), owner: Address.testAccount2)
        wallet2.state = wallet2.deployingState
        repo.save(wallet2)

        let result = repo.filter(by: [.draft, .deploying]).sorted { $0.id.id < $1.id.id }
        XCTAssertEqual(result, [wallet, wallet2].sorted { $0.id.id < $1.id.id })

        repo.remove(wallet)
        XCTAssertNil(repo.findByID(wallet.id))
    }

}
