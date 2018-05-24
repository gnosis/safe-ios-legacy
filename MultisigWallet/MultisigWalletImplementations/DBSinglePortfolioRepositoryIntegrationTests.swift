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
        try repo.setUp()

        let owner = Wallet.createOwner(address: "address")

        let walletRepo = DBWalletRepository(db: db)
        let wallet = try Wallet(id: walletRepo.nextID(), owner: owner, kind: "kind")
        let otherWallet = try Wallet(id: walletRepo.nextID(), owner: owner, kind: "kind")

        let portfolio = Portfolio(id: repo.nextID())
        try portfolio.addWallet(wallet.id)
        try portfolio.addWallet(otherWallet.id)
        try portfolio.selectWallet(otherWallet.id)

        try repo.save(portfolio)
        let saved = try repo.portfolio()
        XCTAssertEqual(saved, portfolio)
        XCTAssertEqual(saved?.selectedWallet, portfolio.selectedWallet)
        XCTAssertEqual(saved?.wallets, portfolio.wallets)

        try repo.remove(portfolio)
        XCTAssertNil(try repo.findByID(portfolio.id))
    }

}
