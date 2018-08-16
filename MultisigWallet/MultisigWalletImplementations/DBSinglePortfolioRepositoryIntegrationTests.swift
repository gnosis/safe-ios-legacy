//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class DBSinglePortfolioRepositoryIntegrationTests: XCTestCase {

    func test_all() throws {
        let db = SQLiteDatabase(name: String(reflecting: self),
                                fileManager: FileManager.default,
                                sqlite: CSQLite3(),
                                bundleId: String(reflecting: self))
        try? db.destroy()
        try db.create()
        defer { try? db.destroy() }

        let repo = DBSinglePortfolioRepository(db: db)
        repo.setUp()

        let walletRepo = DBWalletRepository(db: db)
        let wallet = Wallet(id: walletRepo.nextID(), owner: Address.testAccount1)
        let otherWallet = Wallet(id: walletRepo.nextID(), owner: Address.testAccount1)

        let portfolio = Portfolio(id: repo.nextID())
        portfolio.addWallet(wallet.id)
        portfolio.addWallet(otherWallet.id)
        portfolio.selectWallet(otherWallet.id)

        repo.save(portfolio)
        let saved = repo.portfolio()
        XCTAssertEqual(saved, portfolio)
        XCTAssertEqual(saved?.selectedWallet, portfolio.selectedWallet)
        XCTAssertEqual(saved?.wallets, portfolio.wallets)

        repo.remove(portfolio)
        XCTAssertNil(repo.findByID(portfolio.id))
    }

}
