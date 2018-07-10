//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletImplementations
import MultisigWalletDomainModel
import Common
import CommonTestSupport
import BigInt

class WalletApplicationServiceTests: XCTestCase {

    let walletRepository = MockWalletRepository()
    let portfolioRepository = InMemorySinglePortfolioRepository()
    let accountRepository = InMemoryAccountRepository()
    let blockchainService = MockBlockchainDomainService()
    let service = WalletApplicationService()
    let notificationService = MockNotificationService()

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
        MultisigWalletDomainModel.DomainRegistry.put(service: notificationService, for: NotificationDomainService.self)
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
        blockchainService.requestWalletCreationData_output = WalletCreationData(walletAddress: "address", fee: 100)
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
        XCTAssertEqual(service.selectedWalletState, .addressKnown)
    }

    func test_whenAddingOwner_thenAddressCanBeFound() throws {
        givenDraftWallet()
        try service.addOwner(address: "testAddress", type: .paperWallet)
        XCTAssertEqual(service.ownerAddress(of: .paperWallet), "testAddress")
    }

    func test_whenAddingAlreadyExistingTypeOfOwner_thenOldOwnerIsReplaysed() throws {
        givenDraftWallet()
        try service.addOwner(address: "testAddress", type: .browserExtension)
        try service.addOwner(address: "testAddress", type: .browserExtension)
        XCTAssertEqual(service.ownerAddress(of: .browserExtension), "testAddress")
        try service.addOwner(address: "newTestAddress", type: .browserExtension)
        XCTAssertEqual(service.ownerAddress(of: .browserExtension), "newTestAddress")
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
        assert(state: .addressKnown)
        try service.update(account: "ETH", newBalance: 1)
        assert(state: .notEnoughFunds)
        try service.update(account: "ETH", newBalance: 100)
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
        let account = try findAccount("ETH")
        XCTAssertEqual(account.minimumDeploymentTransactionAmount, 100)
    }

    func test_whenUpdatingAccountBalance_thenUpdatesIt() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
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
        try service.update(account: "ETH", newBalance: 1)
        try service.update(account: "ETH", newBalance: 2)
        try service.markDeploymentAcceptedByBlockchain()
        try service.markDeploymentSuccess()
        try service.finishDeployment()
        XCTAssertTrue(service.hasReadyToUseWallet)
    }

    func test_whenStartingDeployment_thenRequestsBlockchain() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        let expectedOwners = [service.ownerAddress(of: .thisDevice)!,
                              service.ownerAddress(of: .browserExtension)!,
                              service.ownerAddress(of: .paperWallet)!]
        guard let input = blockchainService.requestWalletCreationData_input else {
            XCTFail("Wallet creation was not called")
            return
        }
        XCTAssertEqual(Set(input.owners), Set(expectedOwners))
        XCTAssertEqual(input.confirmationCount, WalletApplicationService.requiredConfirmationCount)
    }

    func test_whenRequestWalletCreationThrows_thenIsInDeployingState() throws {
        givenDraftWallet()
        try addAllOwners()
        blockchainService.shouldThrow = true
        XCTAssertThrowsError(try service.startDeployment())
        XCTAssertEqual(service.selectedWalletState, .readyToDeploy)
    }

    func test_whenRequestWalletCreationReturnsData_thenAssignsSafeAddress() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        XCTAssertEqual(service.selectedWalletState, .addressKnown)
        let account = try findAccount("ETH")
        XCTAssertEqual(account.minimumDeploymentTransactionAmount, 100)
        XCTAssertEqual(account.balance, 0)
        let wallet = try selectedWallet()
        XCTAssertEqual(wallet.address, BlockchainAddress(value: "address"))
    }

    func test_whenDeploymentStarted_thenStartsObservingBalance() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        guard let input = blockchainService.observeBalance_input else {
            XCTFail("Expected to start observing balance")
            return
        }
        let wallet = try selectedWallet()
        XCTAssertEqual(input.account, wallet.address?.value)
    }

    func test_whenBalanceUpdated_thenUpdatesAccount() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        blockchainService.updateBalance(1)
        let account = try findAccount("ETH")
        XCTAssertEqual(account.balance, 1)
    }

    func test_whenBalanceReachesMinimum_thenStopsObserving() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        let account = try findAccount("ETH")
        let requiredBalance = account.minimumDeploymentTransactionAmount
        let response1 = blockchainService.updateBalance(BigInt(requiredBalance - 1))
        XCTAssertEqual(response1, .continueObserving)
        let response2 = blockchainService.updateBalance(BigInt(requiredBalance))
        XCTAssertEqual(response2, .stopObserving)
    }

    func test_whenAccountFunded_thenStartsCreatingSafe() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        blockchainService.updateBalance(100)
        guard let input = blockchainService.executeWalletCreationTransaction_input else {
            XCTFail("Expected createWallet call")
            return
        }
        let wallet = try selectedWallet()
        XCTAssertEqual(input, wallet.address?.value)
    }

    func test_whenStartedCreatingSafe_thenChangesState() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        blockchainService.updateBalance(100)
        assert(state: .readyToUse)
    }

    func test_whenCreatedSafeErrors_thenFailsDeployment() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        blockchainService.executeWalletCreationTransaction_shouldThrow = true
        blockchainService.updateBalance(100)
        assert(state: .deploymentFailed)
    }

    func test_whenDeploymentSuccessful_thenMarksSo() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        blockchainService.updateBalance(100)
        assert(state: .readyToUse)
    }

    func test_whenDeploymentSuccessful_thenRemovesPaperWallet() throws {
        givenDraftWallet()
        try addAllOwners()
        let paperWallet = service.ownerAddress(of: .paperWallet)!
        try service.startDeployment()
        blockchainService.updateBalance(100)
        XCTAssertEqual(blockchainService.removedAddress, paperWallet)
    }

    func test_whenAddressIsKnown_thenReturnsIt() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        XCTAssertNotNil(service.selectedWalletAddress)
    }

    func test_whenAccountMinimumAmountIsKnown_thenReturnsIt() throws {
        givenDraftWallet()
        try addAllOwners()
        try service.startDeployment()
        XCTAssertNotNil(service.minimumDeploymentAmount)
    }

    func test_whenErrorOccursDuringResumeDeployment_thenAborts() throws {
        givenDraftWallet()
        try addAllOwners()
        walletRepository.shouldThrow = true
        XCTAssertThrowsError(try service.startDeployment())
        assert(state: .readyToDeploy)
    }

    func test_whenResumesFromStartedDeployment_thenRequestsDataAgain() throws {
        givenDraftWallet()
        try addAllOwners()
        try markDeploymentStarted()
        try service.startDeployment()
        assert(state: .addressKnown)
    }

    func test_whenResumesFromNotEnoughFunds_thenStartsObservingBalance() throws {
        givenDraftWallet()
        try addAllOwners()
        try markDeploymentStarted()
        try assignAddress("address")
        try makeNotEnoughFunds()
        try service.startDeployment()
        XCTAssertNotNil(blockchainService.observeBalance_input)
    }

    func test_whenResumingFromEnoughFunds_thenStartsWalletCreation() throws {
        givenDraftWallet()
        try addAllOwners()
        try markDeploymentStarted()
        try assignAddress("address")
        try makeEnoughFunds()
        try service.startDeployment()
        XCTAssertNotNil(blockchainService.executeWalletCreationTransaction_input)
    }

    func test_whenResumingFromAcceptedByBlockchain_thenStartsObserving() throws {
        givenDraftWallet()
        try addAllOwners()
        try markDeploymentStarted()
        try assignAddress("address")
        try makeEnoughFunds()
        try markAcceptedByBlockchain()
        try simulateCreationTransaction()
        try service.startDeployment()
        XCTAssertNotNil(blockchainService.waitForPendingTransaction_input)
    }

    func test_whenAddressKnown_thenStartsObservingBalance() throws {
        givenDraftWallet()
        try addAllOwners()
        try markDeploymentStarted()
        try assignAddress("address")
        try service.startDeployment()
        XCTAssertNotNil(blockchainService.observeBalance_input)
    }

    func test_whenAddingBrowserExtensionOwner_thenWorksProperly() throws {
        givenDraftWallet()
        try service.addBrowserExtensionOwner(
            address: "test",
            browserExtensionCode: BrowserExtensionFixture.testJSON)
        XCTAssertTrue(blockchainService.didSign)
        XCTAssertTrue(notificationService.didPair)
        XCTAssertNotNil(service.ownerAddress(of: .browserExtension))
    }

    func test_whenAddingBrowserExtensionOwnerWithNetworkFailure_thenThrowsError() throws {
        givenDraftWallet()
        notificationService.shouldThrow = true
        XCTAssertThrowsError(
            try service.addBrowserExtensionOwner(
                address: "test",
                browserExtensionCode: BrowserExtensionFixture.testJSON)) { error in
                    XCTAssertEqual(error as! WalletApplicationService.Error, .unknownError)
        }
    }

}

class MockWalletRepository: InMemoryWalletRepository {

    var shouldThrow = false

    enum Error: String, LocalizedError, Hashable {
        case error
    }

    override func save(_ wallet: Wallet) throws {
        if shouldThrow { throw Error.error }
        try super.save(wallet)
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

    private func markDeploymentStarted() throws {
        let wallet = try selectedWallet()
        try wallet.startDeployment()
        try walletRepository.save(wallet)
    }

    private func assignAddress(_ address: String) throws {
        let wallet = try selectedWallet()
        try wallet.changeBlockchainAddress(BlockchainAddress(value: address))
        try walletRepository.save(wallet)
    }

    private func makeNotEnoughFunds() throws {
        let account = try findAccount("ETH")
        account.updateMinimumTransactionAmount(100)
        account.update(newAmount: 50)
        try accountRepository.save(account)
    }

    private func makeEnoughFunds() throws {
        let account = try findAccount("ETH")
        account.updateMinimumTransactionAmount(100)
        account.update(newAmount: 150)
        try accountRepository.save(account)
    }

    private func simulateCreationTransaction() throws {
        let wallet = try selectedWallet()
        try wallet.assignCreationTransaction(hash: "something")
        try walletRepository.save(wallet)
    }

    private func markAcceptedByBlockchain() throws {
        let wallet = try selectedWallet()
        try wallet.markDeploymentAcceptedByBlockchain()
        try walletRepository.save(wallet)
    }

}
