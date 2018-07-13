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
        let account = Account(id: AccountID(token: "ETH"),
                              walletID: walletID,
                              balance: 123,
                              minimumAmount: 12)
        repo.save(account)
        let saved = repo.find(id: account.id, walletID: walletID)
        XCTAssertEqual(saved, account)
        XCTAssertEqual(saved?.balance, account.balance)
        XCTAssertEqual(saved?.minimumDeploymentTransactionAmount, account.minimumDeploymentTransactionAmount)

        repo.remove(account)
        XCTAssertNil(repo.find(id: account.id, walletID: walletID))
    }

}
