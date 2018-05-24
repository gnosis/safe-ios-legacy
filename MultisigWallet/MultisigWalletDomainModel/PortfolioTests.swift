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
    var owner = Owner(address: BlockchainAddress(value: "address"))

    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(portfolio = Portfolio(id: try PortfolioID()))
        XCTAssertNoThrow(wallet = try Wallet(id: try WalletID(), owner: owner, kind: "kind"))
        XCTAssertNoThrow(wallet1 = try Wallet(id: try WalletID(), owner: owner, kind: "kind"))
        XCTAssertNoThrow(wallet2 = try Wallet(id: try WalletID(), owner: owner, kind: "kind"))
    }

    func test_whenCreated_thenHasID() throws {
        XCTAssertNotNil(portfolio.id)
    }

    func test_whenFirstWalletAdded_thenItIsSelected() throws {
        try portfolio.addWallet(wallet.id)
        XCTAssertEqual(portfolio.selectedWallet, wallet.id)
    }

    func test_whenAddingExistingWallet_thenThrows() throws {
        try portfolio.addWallet(wallet.id)
        XCTAssertThrowsError(try portfolio.addWallet(wallet.id))
    }

    func test_whenRemovingWallet_thenRemoves() throws {
        try portfolio.addWallet(wallet.id)
        try portfolio.removeWallet(wallet.id)
        XCTAssertNil(portfolio.selectedWallet)
    }

    func test_whenAddingMultipleWallets_thenCanFetchAll() throws {
        try portfolio.addWallet(wallet1.id)
        try portfolio.addWallet(wallet2.id)
        XCTAssertEqual(portfolio.wallets, [wallet1.id, wallet2.id])
    }

    func test_whenRemovingInexistingWallet_thenThrows() throws {
        XCTAssertThrowsError(try portfolio.removeWallet(wallet.id))
    }

    func test_whenSelectingInexistingWallet_thenThrows() throws {
        XCTAssertThrowsError(try portfolio.selectWallet(wallet.id))
    }

    func test_whenSelectingWallet_thenItIsSelected() throws {
        try portfolio.addWallet(wallet1.id)
        try portfolio.addWallet(wallet2.id)
        try portfolio.selectWallet(wallet2.id)
        XCTAssertEqual(portfolio.selectedWallet, wallet2.id)
    }

}
