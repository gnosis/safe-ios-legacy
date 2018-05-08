//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class PortfolioTests: XCTestCase {

    func test_whenCreated_thenHasID() throws {
        let portfolio = Portfolio(id: try PortfolioID())
        XCTAssertNotNil(portfolio.id)
    }

    func test_whenFirstWalletAdded_thenItIsSelected() throws {
        let portfolio = Portfolio(id: try PortfolioID())
        let wallet = Wallet(id: try WalletID())
        try portfolio.addWallet(wallet.id)
        XCTAssertEqual(portfolio.selectedWallet, wallet.id)
    }

    func test_whenAddingExistingWallet_thenThrows() throws {
        let portfolio = Portfolio(id: try PortfolioID())
        let wallet = Wallet(id: try WalletID())
        try portfolio.addWallet(wallet.id)
        XCTAssertThrowsError(try portfolio.addWallet(wallet.id))
    }

    func test_whenRemovingWallet_thenRemoves() throws {
        let portfolio = Portfolio(id: try PortfolioID())
        let wallet = Wallet(id: try WalletID())
        try portfolio.addWallet(wallet.id)
        try portfolio.removeWallet(wallet.id)
        XCTAssertNil(portfolio.selectedWallet)
    }

    func test_whenAddingMultipleWallets_thenCanFetchAll() throws {
        let portfolio = Portfolio(id: try PortfolioID())
        let wallet1 = Wallet(id: try WalletID())
        let wallet2 = Wallet(id: try WalletID())
        try portfolio.addWallet(wallet1.id)
        try portfolio.addWallet(wallet2.id)
        XCTAssertEqual(portfolio.wallets, [wallet1.id, wallet2.id])
    }

    func test_whenRemovingInexistingWallet_thenThrows() throws {
        let portfolio = Portfolio(id: try PortfolioID())
        let wallet = Wallet(id: try WalletID())
        XCTAssertThrowsError(try portfolio.removeWallet(wallet.id))
    }

    func test_whenSelectingInexistingWallet_thenThrows() throws {
        let portfolio = Portfolio(id: try PortfolioID())
        let wallet = Wallet(id: try WalletID())
        XCTAssertThrowsError(try portfolio.selectWallet(wallet.id))
    }

    func test_whenSelectingWallet_thenItIsSelected() throws {
        let portfolio = Portfolio(id: try PortfolioID())
        let wallet1 = Wallet(id: try WalletID())
        let wallet2 = Wallet(id: try WalletID())
        try portfolio.addWallet(wallet1.id)
        try portfolio.addWallet(wallet2.id)
        try portfolio.selectWallet(wallet2.id)
        XCTAssertEqual(portfolio.selectedWallet, wallet2.id)
    }

}
