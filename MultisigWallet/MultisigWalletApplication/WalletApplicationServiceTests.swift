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

    enum Error: String, LocalizedError, Hashable {
        case walletNotFound
    }

    override func setUp() {
        super.setUp()
        MultisigWalletDomainModel.DomainRegistry.put(service: walletRepository, for: WalletRepository.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: portfolioRepository, for: SinglePortfolioRepository.self)
    }

    func test_whenCreatingNewDraft_thenCreatesPortfolio() throws {
        try service.createNewDraftWallet()
        XCTAssertNotNil(try portfolioRepository.portfolio())
    }

    private func createPortfolio(line: UInt = #line) {
        XCTAssertNoThrow(try portfolioRepository.save(Portfolio(id: portfolioRepository.nextID())), line: line)
    }

    private func selectedWallet() throws -> Wallet {
        guard let portfolio = try portfolioRepository.portfolio(),
            let walletID = portfolio.selectedWallet,
            let wallet = try walletRepository.findByID(walletID) else {
                throw Error.walletNotFound
        }
        return wallet
    }

    func test_whenCreatingNewDraft_thenCreatesNewWallet() throws {
        givenDraftWallet()
        XCTAssertEqual(try selectedWallet().status, .newDraft)
    }

    private func givenDraftWallet(line: UInt = #line) {
        createPortfolio(line: line)
        XCTAssertNoThrow(try service.createNewDraftWallet(), line: line)
    }

    func test_whenDeploymentStarted_thenInPendingState() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        XCTAssertEqual(try selectedWallet().status, .deploymentPending)
    }

    func test_whenAddingOwner_thenAddressCanBeFound() throws {
        givenDraftWallet()
        try service.addOwner(address: "address", type: .thisDevice)
        XCTAssertEqual(service.ownerAddress(of: .thisDevice), "address")
    }

    func test_whenAddedEnoughOwners_thenWalletIsReadyToDeploy() throws {
        givenDraftWallet()
        try addAllOwners()
        XCTAssertEqual(service.selectedWalletState, .readyToDeploy)
    }

    private func addAllOwners() throws {
        try service.addOwner(address: "address1", type: .thisDevice)
        try service.addOwner(address: "address2", type: .browserExtension)
        try service.addOwner(address: "address3", type: .paperWallet)
    }

    func test_whenNotReadyToDeploy_thenCantStartDeployment() {
        givenDraftWallet()
        XCTAssertThrowsError(try service.startDeployment())
    }

}
