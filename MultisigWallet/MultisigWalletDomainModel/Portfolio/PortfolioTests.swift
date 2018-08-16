//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class PortfolioTests: XCTestCase {

    var portfolio: Portfolio!
    var wallet: Wallet!
    var wallet1: Wallet!
    var wallet2: Wallet!
    var owner = Address.deviceAddress

    override func setUp() {
        super.setUp()
        portfolio = Portfolio(id: PortfolioID())
        wallet = Wallet(id: WalletID(), owner: owner)
        wallet1 = Wallet(id: WalletID(), owner: owner)
        wallet2 = Wallet(id: WalletID(), owner: owner)
    }

    func test_whenCreated_thenHasID() {
        XCTAssertNotNil(portfolio.id)
    }

    func test_whenFirstWalletAdded_thenItIsSelected() {
        portfolio.addWallet(wallet.id)
        XCTAssertEqual(portfolio.selectedWallet, wallet.id)
    }

    func test_whenRemovingWallet_thenRemoves() {
        portfolio.addWallet(wallet.id)
        portfolio.removeWallet(wallet.id)
        XCTAssertNil(portfolio.selectedWallet)
    }

    func test_whenAddingMultipleWallets_thenCanFetchAll() {
        portfolio.addWallet(wallet1.id)
        portfolio.addWallet(wallet2.id)
        XCTAssertEqual(portfolio.wallets, [wallet1.id, wallet2.id])
    }

    func test_whenSelectingWallet_thenItIsSelected() {
        portfolio.addWallet(wallet1.id)
        portfolio.addWallet(wallet2.id)
        portfolio.selectWallet(wallet2.id)
        XCTAssertEqual(portfolio.selectedWallet, wallet2.id)
    }

}
