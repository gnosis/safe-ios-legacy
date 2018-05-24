//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletImplementations
import MultisigWalletDomainModel
import Common

class WalletApplicationServiceTests: XCTestCase {

    let walletRepository = InMemoryWalletRepository()
    let portfolioRepository = InMemorySinglePortfolioRepository()
    let accountRepository = InMemoryAccountRepository()
    let blockchainService = MockBlockchainDomainService()
    let service = WalletApplicationService()

    enum Error: String, LocalizedError, Hashable {
        case walletNotFound
        case accountNotFound
    }

    override func setUp() {
        super.setUp()
        MultisigWalletDomainModel.DomainRegistry.put(service: walletRepository, for: WalletRepository.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: portfolioRepository, for: SinglePortfolioRepository.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: accountRepository, for: AccountRepository.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: blockchainService, for: BlockchainDomainService.self)
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
    }

    func test_whenCreatingNewDraft_thenCreatesPortfolio() throws {
        try service.createNewDraftWallet()
        XCTAssertNotNil(try portfolioRepository.portfolio())
    }

    func test_whenCreatingNewDraft_thenCreatesNewWallet() throws {
        givenDraftWallet()
        XCTAssertEqual(try selectedWallet().status, .newDraft)
    }

    func test_whenAssigningAddress_thenCanFetchIt() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        try service.assignBlockchainAddress("address")
        XCTAssertEqual(try selectedWallet().address?.value, "address")
    }

    func test_whenAddingAccount_thenCanFindIt() throws {
        givenDraftWallet()
        let wallet = try selectedWallet()
        let eth = AccountID(token: "ETH")
        let account = try accountRepository.find(id: eth, walletID: wallet.id)
        XCTAssertNotNil(account)
        XCTAssertEqual(account?.id, eth)
        XCTAssertEqual(account?.balance, 0)
    }

    func test_whenDeploymentStarted_thenInPendingState() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        XCTAssertEqual(service.selectedWalletState, .deploymentStarted)
    }

    func test_whenAddingOwner_thenAddressCanBeFound() throws {
        givenDraftWallet()
        try service.addOwner(address: "testAddress", type: .paperWallet)
        XCTAssertEqual(service.ownerAddress(of: .paperWallet), "testAddress")
    }

    fileprivate func givenReadyToDeployWallet(line: UInt = #line) throws {
        givenDraftWallet(line: line)
        try addAllOwners()
    }

    func test_whenAddedEnoughOwners_thenWalletIsReadyToDeploy() throws {
        try givenReadyToDeployWallet()
        XCTAssertEqual(service.selectedWalletState, .readyToDeploy)
    }

    func test_whenNotReadyToDeploy_thenCantStartDeployment() {
        givenDraftWallet()
        XCTAssertThrowsError(try service.startDeployment())
    }

    func test_fullCycle() throws {
        createPortfolio()
        assert(state: .none)
        try service.createNewDraftWallet()
        assert(state: .newDraft)
        try addAllOwners()
        assert(state: .readyToDeploy)
        try service.startDeployment()
        assert(state: .deploymentStarted)
        try service.assignBlockchainAddress("address")
        assert(state: .addressKnown)
        try service.updateMinimumFunding(account: "ETH", amount: 2)
        assert(state: .notEnoughFunds)
        try service.update(account: "ETH", newBalance: 1)
        assert(state: .notEnoughFunds)
        try service.update(account: "ETH", newBalance: 2)
        assert(state: .accountFunded)
        try service.markDeploymentAcceptedByBlockchain()
        assert(state: .deploymentAcceptedByBlockchain)
        try service.markDeploymentSuccess()
        assert(state: .deploymentSuccess)
        try service.finishDeployment()
        assert(state: .readyToUse)
    }

    func test_whenUpdatingMinimumAmount_thenCanRetrieveIt() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        try service.assignBlockchainAddress("address")
        try service.updateMinimumFunding(account: "ETH", amount: 100)
        let account = try findAccount("ETH")
        XCTAssertEqual(account.minimumTransactionAmount, 100)
    }

    func test_whenUpdatingAccountBalance_thenUpdatesIt() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        try service.assignBlockchainAddress("address")
        try service.update(account: "ETH", newBalance: 100)
        let account = try findAccount("ETH")
        XCTAssertEqual(account.balance, 100)
    }

    func test_whenSubscribesForUpdates_thenReceivesThem() throws {
        givenDraftWallet()
        var updated = false
        _ = service.subscribe {
            updated = true
        }
        try addAllOwners()
        XCTAssertTrue(updated)
    }

    func test_whenUnsubscribes_thenNoUpdatesReceived() throws {
        givenDraftWallet()
        var updated = false
        let handle = service.subscribe {
            updated = true
        }
        service.unsubscribe(subscription: handle)
        try addAllOwners()
        XCTAssertFalse(updated)
    }

    func test_whenCreatingFirstWallet_thenCanObserveStatusUpdate() {
        var updated = false
        _ = service.subscribe {
            updated = true
        }
        givenDraftWallet()
        XCTAssertTrue(updated)
    }

    func test_whenWalletIsReady_thenHasReadyState() throws {
        createPortfolio()
        try service.createNewDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        try service.assignBlockchainAddress("address")
        try service.updateMinimumFunding(account: "ETH", amount: 2)
        try service.update(account: "ETH", newBalance: 1)
        try service.update(account: "ETH", newBalance: 2)
        try service.markDeploymentAcceptedByBlockchain()
        try service.markDeploymentSuccess()
        try service.finishDeployment()
        XCTAssertTrue(service.hasReadyToUseWallet)
    }

}

fileprivate extension WalletApplicationServiceTests {

    func addAllOwners() throws {
        try service.addOwner(address: "address2", type: .browserExtension)
        try service.addOwner(address: "address3", type: .paperWallet)
    }

    func createPortfolio(line: UInt = #line) {
        XCTAssertNoThrow(try portfolioRepository.save(Portfolio(id: portfolioRepository.nextID())), line: line)
    }

    func selectedWallet() throws -> Wallet {
        guard let portfolio = try portfolioRepository.portfolio(),
            let walletID = portfolio.selectedWallet,
            let wallet = try walletRepository.findByID(walletID) else {
                throw Error.walletNotFound
        }
        return wallet
    }

    func assert(state: WalletApplicationService.WalletState, line: UInt = #line) {
        XCTAssertEqual(service.selectedWalletState, state, line: line)
    }

    func findAccount(_ token: String) throws -> Account {
        let wallet = try selectedWallet()
        guard let account = try accountRepository.find(id: AccountID(token: "ETH"), walletID: wallet.id) else {
            throw Error.accountNotFound
        }
        return account
    }

    func givenDraftWallet(line: UInt = #line) {
        createPortfolio(line: line)
        XCTAssertNoThrow(try service.createNewDraftWallet(), line: line)
    }

}
