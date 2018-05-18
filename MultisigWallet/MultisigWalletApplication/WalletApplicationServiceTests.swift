//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletImplementations
import MultisigWalletDomainModel

class WalletApplicationServiceTests: XCTestCase {

    let walletRepository = InMemoryWalletRepository()
    let portfolioRepository = InMemorySinglePortfolioRepository()
    let service = WalletApplicationService()

    override func setUp() {
        super.setUp()
        MultisigWalletDomainModel.DomainRegistry.put(service: walletRepository, for: WalletRepository.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: portfolioRepository, for: SinglePortfolioRepository.self)
    }

    func test_whenCreatingNewDraft_thenCreatesPortfolio() throws {
        try service.createNewDraftWallet()
        XCTAssertNotNil(try portfolioRepository.portfolio())
    }

    func test_whenCreatingNewDraft_thenCreatesNewWallet() throws {
        try portfolioRepository.save(Portfolio(id: portfolioRepository.nextID()))
        try service.createNewDraftWallet()
        guard let portfolio = try portfolioRepository.portfolio() else {
            XCTFail("Failed to find portfolio")
            return
        }
        guard let walletID = portfolio.selectedWallet, let wallet = try walletRepository.findByID(walletID) else {
            XCTFail("Wallet was not created and selected")
            return
        }
        XCTAssertEqual(wallet.status, .newDraft)
    }

}
