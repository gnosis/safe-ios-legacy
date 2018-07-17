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

    let walletRepository = InMemoryWalletRepository()
    let portfolioRepository = InMemorySinglePortfolioRepository()
    let accountRepository = InMemoryAccountRepository()
    let ethereumService = MockEthereumApplicationService()
    let service = WalletApplicationService()
    let notificationService = MockNotificationService()
    let tokensService = MockTokensDomainService()

    enum Error: String, LocalizedError, Hashable {
        case walletNotFound
        case accountNotFound
    }

    override func setUp() {
        super.setUp()
        MultisigWalletDomainModel.DomainRegistry.put(service: walletRepository, for: WalletRepository.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: portfolioRepository, for: SinglePortfolioRepository.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: accountRepository, for: AccountRepository.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: notificationService, for: NotificationDomainService.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: tokensService, for: TokensDomainService.self)
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: ethereumService,
                                                                 for: EthereumApplicationService.self)
        ethereumService.createSafeCreationTransaction_output =
            SafeCreationTransactionData(safe: Address.safeAddress.value, payment: 100)
        ethereumService.prepareToGenerateExternallyOwnedAccount(address: Address.deviceAddress.value,
                                                                mnemonic: ["a", "b"])
    }

    func test_whenCreatingNewDraft_thenCreatesPortfolio() throws {
        service.createNewDraftWallet()
        XCTAssertNotNil(portfolioRepository.portfolio())
    }

    func test_whenCreatingNewDraft_thenCreatesNewWallet() throws {
        givenDraftWallet()
        XCTAssertEqual(try selectedWallet().status, .newDraft)
    }

    func test_whenAssigningAddress_thenCanFetchIt() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        XCTAssertEqual(try selectedWallet().address, Address.safeAddress)
    }

    func test_whenAddingAccount_thenCanFindIt() throws {
        givenDraftWallet()
        let wallet = try selectedWallet()
        let eth = AccountID(token: "ETH")
        let account = accountRepository.find(id: eth, walletID: wallet.id)
        XCTAssertNotNil(account)
        XCTAssertEqual(account?.id, eth)
        XCTAssertEqual(account?.balance, 0)
    }

    func test_whenDeploymentStarted_thenInPendingState() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        XCTAssertEqual(service.selectedWalletState, .addressKnown)
    }

    func test_whenAddingOwner_thenAddressCanBeFound() throws {
        givenDraftWallet()
        service.addOwner(address: Address.paperWalletAddress.value, type: .paperWallet)
        XCTAssertEqual(service.ownerAddress(of: .paperWallet), Address.paperWalletAddress.value)
    }

    func test_whenAddingAlreadyExistingTypeOfOwner_thenOldOwnerIsReplaced() throws {
        givenDraftWallet()
        service.addOwner(address: Address.extensionAddress.value, type: .browserExtension)
        service.addOwner(address: Address.extensionAddress.value, type: .browserExtension)
        XCTAssertEqual(service.ownerAddress(of: .browserExtension), Address.extensionAddress.value)
        service.addOwner(address: Address.testAccount1.value, type: .browserExtension)
        XCTAssertEqual(service.ownerAddress(of: .browserExtension), Address.testAccount1.value)
    }

    fileprivate func givenReadyToDeployWallet(line: UInt = #line) throws {
        givenDraftWallet()
        addAllOwners()
    }

    func test_whenAddedEnoughOwners_thenWalletIsReadyToDeploy() throws {
        try givenReadyToDeployWallet()
        XCTAssertEqual(service.selectedWalletState, .readyToDeploy)
    }

    func test_fullCycle() throws {
        createPortfolio()
        assert(state: .none)
        service.createNewDraftWallet()
        assert(state: .newDraft)
        addAllOwners()
        assert(state: .readyToDeploy)
        try service.startDeployment()
        assert(state: .addressKnown)
        service.update(account: "ETH", newBalance: 1)
        assert(state: .notEnoughFunds)
        service.update(account: "ETH", newBalance: 100)
        assert(state: .accountFunded)
        service.markDeploymentAcceptedByBlockchain()
        assert(state: .deploymentAcceptedByBlockchain)
        service.markDeploymentSuccess()
        assert(state: .deploymentSuccess)
        service.finishDeployment()
        assert(state: .readyToUse)
    }

    func test_whenUpdatingMinimumAmount_thenCanRetrieveIt() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        let account = try findAccount("ETH")
        XCTAssertEqual(account.minimumDeploymentTransactionAmount, 100)
    }

    func test_whenUpdatingAccountBalance_thenUpdatesIt() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        service.update(account: "ETH", newBalance: 100)
        let account = try findAccount("ETH")
        XCTAssertEqual(account.balance, 100)
    }

    func test_whenSubscribesForUpdates_thenReceivesThem() throws {
        givenDraftWallet()
        var updated = false
        _ = service.subscribe {
            updated = true
        }
        addAllOwners()
        XCTAssertTrue(updated)
    }

    func test_whenUnsubscribes_thenNoUpdatesReceived() throws {
        givenDraftWallet()
        var updated = false
        let handle = service.subscribe {
            updated = true
        }
        service.unsubscribe(subscription: handle)
        addAllOwners()
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
        service.createNewDraftWallet()
        addAllOwners()
        try service.startDeployment()
        service.update(account: "ETH", newBalance: 1)
        service.update(account: "ETH", newBalance: 2)
        service.markDeploymentAcceptedByBlockchain()
        service.markDeploymentSuccess()
        service.finishDeployment()
        XCTAssertTrue(service.hasReadyToUseWallet)
    }

    func test_whenStartingDeployment_thenRequestsBlockchain() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        let expectedOwners = [service.ownerAddress(of: .thisDevice)!,
                              service.ownerAddress(of: .browserExtension)!,
                              service.ownerAddress(of: .paperWallet)!].map { Address($0) }
        guard let input = ethereumService.createSafeCreationTransaction_input else {
            XCTFail("Wallet creation was not called")
            return
        }
        XCTAssertEqual(Set(input.owners), Set(expectedOwners))
        XCTAssertEqual(input.confirmationCount, WalletApplicationService.requiredConfirmationCount)
    }

    func test_whenRequestWalletCreationThrows_thenIsInDeployingState() throws {
        givenDraftWallet()
        addAllOwners()
        ethereumService.shouldThrow = true
        XCTAssertThrowsError(try service.startDeployment())
        XCTAssertEqual(service.selectedWalletState, .readyToDeploy)
    }

    func test_whenRequestWalletCreationReturnsData_thenAssignsSafeAddress() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        XCTAssertEqual(service.selectedWalletState, .addressKnown)
        let account = try findAccount("ETH")
        XCTAssertEqual(account.minimumDeploymentTransactionAmount, 100)
        XCTAssertEqual(account.balance, 0)
        let wallet = try selectedWallet()
        XCTAssertEqual(wallet.address, Address.safeAddress)
    }

    func test_whenDeploymentStarted_thenStartsObservingBalance() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        guard let input = ethereumService.observeChangesInBalance_input else {
            XCTFail("Expected to start observing balance")
            return
        }
        let wallet = try selectedWallet()
        XCTAssertEqual(input.account, wallet.address?.value)
    }

    func test_whenBalanceUpdated_thenUpdatesAccount() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        ethereumService.updateBalance(1)
        let account = try findAccount("ETH")
        XCTAssertEqual(account.balance, 1)
    }

    func test_whenBalanceReachesMinimum_thenStopsObserving() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        let account = try findAccount("ETH")
        let requiredBalance = account.minimumDeploymentTransactionAmount
        let response1 = ethereumService.updateBalance(BigInt(requiredBalance - 1))
        XCTAssertEqual(response1, RepeatingShouldStop.no)
        let response2 = ethereumService.updateBalance(BigInt(requiredBalance))
        XCTAssertEqual(response2, RepeatingShouldStop.yes)
    }

    func test_whenAccountFunded_thenStartsCreatingSafe() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        ethereumService.updateBalance(100)
        guard let input = ethereumService.startSafeCreation_input else {
            XCTFail("Expected createWallet call")
            return
        }
        let wallet = try selectedWallet()
        XCTAssertEqual(input, wallet.address)
    }

    func test_whenStartedCreatingSafe_thenChangesState() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        ethereumService.updateBalance(100)
        assert(state: .readyToUse)
    }

    func test_whenCreatedSafeErrors_thenFailsDeployment() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        ethereumService.startSafeCreation_shouldThrow = true
        ethereumService.updateBalance(100)
        assert(state: .deploymentFailed)
    }

    func test_whenDeploymentSuccessful_thenMarksSo() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        ethereumService.updateBalance(100)
        assert(state: .readyToUse)
    }

    func test_whenDeploymentSuccessful_thenRemovesPaperWallet() throws {
        givenDraftWallet()
        addAllOwners()
        let paperWallet = service.ownerAddress(of: .paperWallet)!
        try service.startDeployment()
        ethereumService.updateBalance(100)
        XCTAssertEqual(ethereumService.removedAddress, paperWallet)
    }

    func test_whenAddressIsKnown_thenReturnsIt() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        XCTAssertNotNil(service.selectedWalletAddress)
    }

    func test_whenAccountMinimumAmountIsKnown_thenReturnsIt() throws {
        givenDraftWallet()
        addAllOwners()
        try service.startDeployment()
        XCTAssertNotNil(service.minimumDeploymentAmount)
    }

    func test_whenResumesFromStartedDeployment_thenRequestsDataAgain() throws {
        givenDraftWallet()
        addAllOwners()
        try markDeploymentStarted()
        try service.startDeployment()
        assert(state: .addressKnown)
    }

    func test_whenResumesFromNotEnoughFunds_thenStartsObservingBalance() throws {
        givenDraftWallet()
        addAllOwners()
        try markDeploymentStarted()
        try assignAddress(Address.safeAddress.value)
        try makeNotEnoughFunds()
        try service.startDeployment()
        XCTAssertNotNil(ethereumService.observeChangesInBalance_input)
    }

    func test_whenResumingFromEnoughFunds_thenStartsWalletCreation() throws {
        givenDraftWallet()
        addAllOwners()
        try markDeploymentStarted()
        try assignAddress(Address.safeAddress.value)
        try makeEnoughFunds()
        try service.startDeployment()
        XCTAssertNotNil(ethereumService.startSafeCreation_input)
    }

    func test_whenResumingFromAcceptedByBlockchain_thenStartsObserving() throws {
        givenDraftWallet()
        addAllOwners()
        try markDeploymentStarted()
        try assignAddress(Address.safeAddress.value)
        try makeEnoughFunds()
        try markAcceptedByBlockchain()
        try simulateCreationTransaction()
        try service.startDeployment()
        XCTAssertNotNil(ethereumService.waitForPendingTransaction_input)
    }

    func test_whenAddressKnown_thenStartsObservingBalance() throws {
        givenDraftWallet()
        addAllOwners()
        try markDeploymentStarted()
        try assignAddress(Address.safeAddress.value)
        try service.startDeployment()
        XCTAssertNotNil(ethereumService.observeChangesInBalance_input)
    }

    // - MARK: Pairing with Browser Extension

    func test_whenAddingBrowserExtensionOwner_thenWorksProperly() throws {
        givenDraftWallet()
        try service.addBrowserExtensionOwner(
            address: Address.extensionAddress.value,
            browserExtensionCode: BrowserExtensionFixture.testJSON)
        XCTAssertTrue(ethereumService.didSign)
        XCTAssertTrue(notificationService.didPair)
        XCTAssertNotNil(service.ownerAddress(of: .browserExtension))
    }

    func test_whenAddingBrowserExtensionOwnerWithNetworkFailure_thenThrowsError() throws {
        givenDraftWallet()
        notificationService.shouldThrow = true
        XCTAssertThrowsError(
            try service.addBrowserExtensionOwner(
                address: Address.extensionAddress.value,
                browserExtensionCode: BrowserExtensionFixture.testJSON)) { error in
                    XCTAssertEqual(error as! WalletApplicationService.Error, .unknownError)
        }
    }


    // - MARK: Auth with Push Token

    func test_whenAuthWithPushTokenCalled_thenCallsNotificationService() throws {
        givenDraftWallet()
        try auth()
        XCTAssertTrue(tokensService.didCallPushToken)
        XCTAssertTrue(notificationService.didAuth)
    }

    func test_whenAuthFailure_thenThrowsError() throws {
        givenDraftWallet()
        notificationService.shouldThrow = true
        XCTAssertThrowsError(try auth()) { error in
            XCTAssertEqual(error as! WalletApplicationService.Error, .unknownError)
        }
        notificationService.shouldThrow = false
        notificationService.shouldThrowNetworkError = true
        XCTAssertThrowsError(try auth()) { error in
            XCTAssertEqual(error as! WalletApplicationService.Error, .networkError)
        }
    }

    private func auth() throws {
        var error: Swift.Error?
        let exp = expectation(description: "Auth")
        DispatchQueue.global().async {
            defer { exp.fulfill() }
            do {
                try self.service.auth()
            } catch let e {
                error = e
            }
        }
        waitForExpectations(timeout: 2)
        if let error = error { throw error }
    }

    // - MARK: Notify on Safe Creation

    func test_whenFinishesDeployment_thenNotifiesExtensionOfSafeCreated() throws {
        createPortfolio()
        service.createNewDraftWallet()
        addAllOwners()
        try service.startDeployment()
        ethereumService.updateBalance(100)

        let walletAddress = service.selectedWalletAddress!
        let message = notificationService.safeCreatedMessage(at: walletAddress)
        let extensionAddress = service.ownerAddress(of: .browserExtension)!
        let deviceAddress = service.ownerAddress(of: .thisDevice)!
        XCTAssertEqual(notificationService.sentMessages, ["to:\(extensionAddress) msg:\(message)"])
        XCTAssertEqual(ethereumService.sign_input?.message, "GNO" + message)
        XCTAssertEqual(ethereumService.sign_input?.signingAddress, deviceAddress)
    }

    func test_canEncodeAndDecodeBrowserExtensionCode() throws {
        let dateFormatter = DateFormatter.networkDateFormatter

        let date = dateFormatter.date(from: "2018-05-09T14:18:55+00:00")!
        let signature = EthSignature(r: "test", s: "me", v: 27)
        let code = BrowserExtensionCode(
            expirationDate: date,
            signature: signature,
            extensionAddress: "address")

        ethereumService.browserExtensionAddress = "address"

        let code2 = service.browserExtensionCode(from: BrowserExtensionFixture.testJSON)
        XCTAssertEqual(code, code2)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let data = try encoder.encode(code)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let code3 = try decoder.decode(BrowserExtensionCode.self, from: data)
        XCTAssertNil(code3.extensionAddress)
        XCTAssertEqual(code.expirationDate, code3.expirationDate)
        XCTAssertEqual(code.signature, code3.signature)
    }

}

fileprivate extension WalletApplicationServiceTests {

    func addAllOwners() {
        service.addOwner(address: Address.extensionAddress.value, type: .browserExtension)
        service.addOwner(address: Address.paperWalletAddress.value, type: .paperWallet)
    }

    func createPortfolio() {
        portfolioRepository.save(Portfolio(id: portfolioRepository.nextID()))
    }

    func selectedWallet() throws -> Wallet {
        guard let portfolio = portfolioRepository.portfolio(),
            let walletID = portfolio.selectedWallet,
            let wallet = walletRepository.findByID(walletID) else {
                throw Error.walletNotFound
        }
        return wallet
    }

    func assert(state: WalletApplicationService.WalletState, line: UInt = #line) {
        XCTAssertEqual(service.selectedWalletState, state, line: line)
    }

    func findAccount(_ token: String) throws -> Account {
        let wallet = try selectedWallet()
        guard let account = accountRepository.find(id: AccountID(token: "ETH"), walletID: wallet.id) else {
            throw Error.accountNotFound
        }
        return account
    }

    func givenDraftWallet() {
        createPortfolio()
        service.createNewDraftWallet()
    }

    private func markDeploymentStarted() throws {
        let wallet = try selectedWallet()
        wallet.startDeployment()
        walletRepository.save(wallet)
    }

    private func assignAddress(_ address: String) throws {
        let wallet = try selectedWallet()
        wallet.changeAddress(Address(address))
        walletRepository.save(wallet)
    }

    private func makeNotEnoughFunds() throws {
        let account = try findAccount("ETH")
        account.updateMinimumTransactionAmount(100)
        account.update(newAmount: 50)
        accountRepository.save(account)
    }

    private func makeEnoughFunds() throws {
        let account = try findAccount("ETH")
        account.updateMinimumTransactionAmount(100)
        account.update(newAmount: 150)
        accountRepository.save(account)
    }

    private func simulateCreationTransaction() throws {
        let wallet = try selectedWallet()
        wallet.assignCreationTransaction(hash: TransactionHash.test1.value)
        walletRepository.save(wallet)
    }

    private func markAcceptedByBlockchain() throws {
        let wallet = try selectedWallet()
        wallet.markDeploymentAcceptedByBlockchain()
        walletRepository.save(wallet)
    }

}
