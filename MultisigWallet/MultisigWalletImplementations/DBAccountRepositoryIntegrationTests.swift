//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class DBAccountRepositoryIntegrationTests: XCTestCase {

    func test_all() throws {
        let db = SQLiteDatabase(name: String(reflecting: self),
                                fileManager: FileManager.default,
                                sqlite: CSQLite3(),
                                bundleId: String(reflecting: self))
        try? db.destroy()
        try db.create()
        defer {
            try? db.destroy()
        }

        let repo = DBAccountRepository(db: db)
        repo.setUp()

        let walletID = WalletID()
        let account = Account(tokenID: Token.gno.id,
                              walletID: walletID,
                              balance: 123)
        repo.save(account)
        let saved = repo.find(id: account.id)
        XCTAssertEqual(saved, account)
        XCTAssertEqual(saved?.balance, account.balance)

        let account2 = Account(tokenID: Token.mgn.id,
                               walletID: walletID,
                               balance: nil)
        repo.save(account2)
        let saved2 = repo.find(id: account2.id)
        XCTAssertEqual(saved2, account2)
        XCTAssertEqual(saved2?.balance, account2.balance)

        let all = repo.all()
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(Set([account, account2]), Set(all))

        repo.remove(account)
        XCTAssertNil(repo.find(id: account.id))
    }

}
