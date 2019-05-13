//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport
import BigInt

class DeploymentServiceEventSubscriptionTests: BaseDeploymentDomainServiceTests {

    func test_whenStartsTwice_thenDoesNotDuplicateEventHandling() {
        eventPublisher.addFilter(DeploymentStarted.self)

        encryptionService.always_return_hash(Data(repeating: 7, count: 32))

        givenDraftWalletWithAllOwners()
        expectSafeCreationTransaction()
        start()

        portfolioRepository.remove(portfolioRepository.portfolio()!)
        walletRepository.remove(wallet)

        givenDraftWalletWithAllOwners()
        expectSafeCreationTransaction()
        start()

        relayService.verify()
    }

}

class DeployingWalletTests: BaseDeploymentDomainServiceTests {

    override func setUp() {
        super.setUp()
        encryptionService.always_return_hash(Data(repeating: 7, count: 32))
        eventPublisher.addFilter(DeploymentStarted.self)
    }

    func test_whenInDraft_thenFetchesCreationTransactionData() {
        givenDraftWalletWithAllOwners()
        expectSafeCreationTransaction()
        start()
        relayService.verify()
    }

    func test_whenFetchedTransactionData_thenUpdatesAddressAndFee() {
        givenDraftWalletWithAllOwners()
        let response = SafeCreationRequest.Response.testResponse()
        relayService.expect_createSafeCreationTransaction(.testRequest(), response)
        start()
        wallet = walletRepository.find(id: wallet.id)!
        XCTAssertEqual(wallet.address, response.safeAddress)
        XCTAssertEqual(wallet.minimumDeploymentTransactionAmount, response.deploymentFee)
    }

    func test_whenCreationTransactionThrows_thenErrorPosted() {
        givenDraftWalletWithAllOwners()
        relayService.expect_createSafeCreationTransaction_throw(TestError.error)
        assertThrows(TestError.error)
    }

    func test_whenCreationTransactionThrows_thenCancelsDeployment() {
        givenDraftWalletWithAllOwners()
        relayService.expect_createSafeCreationTransaction_throw(TestError.error)
        start()
        assertDeploymentCancelled()
    }

    func test_whenNetworkError_thenDoesNotCancel() {
        givenDraftWalletWithAllOwners()
        assertSameStateOnError(NetworkServiceError.clientError)
        assertSameStateOnError(NetworkServiceError.networkError)
        assertSameStateOnError(NSError.urlError)
    }

    private func assertSameStateOnError(_ error: Error, line: UInt = #line) {
        relayService.expect_createSafeCreationTransaction_throw(error)
        start()
        XCTAssertTrue(wallet.state === wallet.deployingState, line: line)
    }

    func test_whenResumes_thenMovesToNextState() {
        givenFundedWallet(with: 50)
        relayService.expect_createSafeCreationTransaction(.testRequest(), .testResponse())
        start()
        XCTAssertTrue(wallet.state === wallet.notEnoughFundsState)
    }

    func test_whenEmptyAccount_thenMovesToFirstDeposit() {
        givenConfiguredWallet()
        relayService.expect_createSafeCreationTransaction(.testRequest(), .testResponse())
        start()
        XCTAssertTrue(wallet.state === wallet.waitingForFirstDepositState)
    }

}

class FirstDepositTests: BaseDeploymentDomainServiceTests {

    override func setUp() {
        super.setUp()
        setupDeploymentService(delay: 10)
        eventPublisher.addFilter(StartedWaitingForFirstDeposit.self)
        givenConfiguredWallet()
    }

    private func setupDeploymentService(delay: TimeInterval = 10) {
        let configParams = DeploymentDomainServiceConfiguration.Parameters(repeatDelay: delay,
                                                                           retryAttempts: 3,
                                                                           retryDelay: delay)
        let config = DeploymentDomainServiceConfiguration(balance: configParams,
                                                          deploymentStatus: configParams,
                                                          transactionStatus: configParams)
        deploymentService = DeploymentDomainService(config)
        deploymentService.responseValidator = MockSafeCreationResponseValidator()
    }

    func test_whenEmptyBalance_thenDoesNothing() {
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 0)
        start()
        nodeService.verify()
        XCTAssertEqual(walletAccount.balance, 0)
    }

    func test_whenGetsFirstDepositNotEnough_thenSwitchesToOtherState() {
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 50)
        start()
        nodeService.verify()
        XCTAssertTrue(wallet.state === wallet.notEnoughFundsState)
    }

    func test_whenEnoughFunds_thenSwitchesToCreation() {
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 100)
        start()
        nodeService.verify()
        XCTAssertTrue(wallet.state === wallet.creationStartedState)
    }

    func test_whenObservingBalanceFails_thenCancels() {
        setupDeploymentService(delay: 0)
        nodeService.expect_eth_getBalance_throw(TestError.error)
        start()
        assertDeploymentCancelled()
    }

}

class ConfiguredWalletTests: BaseDeploymentDomainServiceTests {

    override func setUp() {
        super.setUp()
        eventPublisher.addFilter(StartedWaitingForRemainingFeeAmount.self)
        givenFundedWallet(with: 50)
    }


    func test_whenWalletConfigured_thenObservesBalance() {
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 100)
        start()
        nodeService.verify()
        XCTAssertEqual(walletAccount.balance, 100)
    }

    func test_whenNotEnoughFundsAtFirst_thenRepeatsUntilHasFunds() {
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 50)
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 100)
        start()
        nodeService.verify()
    }

    func test_whenObservingBalanceFails_thenErrorPosted() {
        nodeService.expect_eth_getBalance_throw(TestError.error)
        assertThrows(TestError.error)
    }

    func test_whenObservingBalanceFails_thenCancels() {
        nodeService.expect_eth_getBalance_throw(TestError.error)
        start()
        assertDeploymentCancelled()
    }

}

class DeploymentFundedTests: BaseDeploymentDomainServiceTests {

    override func setUp() {
        super.setUp()
        eventPublisher.addFilter(DeploymentFunded.self)
    }

    func test_whenFunded_thenNotifiesRelayService() {
        givenFundedWallet()
        relayService.expect_startSafeCreation(address: wallet.address!)
        start()
        relayService.verify()
    }

    func test_whenFailsToNotifyService_thenHandlesError() {
        givenFundedWallet()
        relayService.expect_startSafeCreation_throw(TestError.error)
        assertThrows(TestError.error)
    }

    func test_whenFailsToNotifyService_thenCancels() {
        givenFundedWallet()
        relayService.expect_startSafeCreation_throw(TestError.error)
        start()
        assertDeploymentCancelled()
    }

}

class CreationStartedTests: BaseDeploymentDomainServiceTests {

    let successReceipt = TransactionReceipt(hash: TransactionHash.test1, status: .success, blockHash: "0x1")
    let failedReceipt = TransactionReceipt(hash: TransactionHash.test1, status: .failed, blockHash: "0x1")

    override func setUp() {
        super.setUp()
        eventPublisher.addFilter(CreationStarted.self)
    }

    func test_whenFunded_thenRunsSynchronisation() {
        givenDeployingWallet()
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: successReceipt)
        start()
        delay(0.25)
        XCTAssertTrue(syncService.didSync)
    }

    func test_whenFunded_thenWaitsForTransaction() {
        givenDeployingWallet(withoutTransaction: true)
        relayService.expect_safeCreationTransactionHash(address: wallet.address!, hash: nil)
        relayService.expect_safeCreationTransactionHash(address: wallet.address!, hash: TransactionHash.test1)
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: successReceipt)
        start()
        relayService.verify()
        wallet = DomainRegistry.walletRepository.selectedWallet()!
        XCTAssertEqual(wallet.creationTransactionHash, TransactionHash.test1.value)
    }


    func test_whenTransactionKnown_thenWaitsForItsStatus() {
        givenDeployingWallet()
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: successReceipt)
        start()
        relayService.verify()
        nodeService.verify()
        wallet = DomainRegistry.walletRepository.selectedWallet()!
        XCTAssertTrue(wallet.state === wallet.readyToUseState)
    }

    func test_whenTransactionFailed_thenCancels() {
        givenDeployingWallet()
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: failedReceipt)
        start()
        wallet = DomainRegistry.walletRepository.selectedWallet()!
        XCTAssertTrue(wallet.state === wallet.finalizingDeploymentState)
    }

}

class WalletCreatedTests: BaseDeploymentDomainServiceTests {

    override func setUp() {
        super.setUp()
        eventPublisher.addFilter(WalletCreated.self)
    }

    func test_whenCreated_thenNotifiesExtension() {
        givenCreatedWalletWithNotifiedExtension()
        start()
        wallet.proceed()
        delay()
        encryptionService.verify()
        notificationService.verify()
    }

    func test_whenCreated_thenRemovesPaperWallet() {
        givenCreatedWalletWithNotifiedExtension()
        eoaRepository.save(.createTestAccount(wallet,
                                        role: .paperWallet,
                                        privateKey: .testPrivateKey,
                                        publicKey: .testPublicKey))
        eoaRepository.save(.createTestAccount(wallet,
                                        role: .paperWalletDerived,
                                        privateKey: .testPrivateKey,
                                        publicKey: .testPublicKey))

        start()
        wallet.proceed()
        delay()
        XCTAssertNil(eoaRepository.find(by: wallet.owner(role: .paperWallet)!.address))
        XCTAssertNil(eoaRepository.find(by: wallet.owner(role: .paperWalletDerived)!.address))
    }

}

class WalletCreationFailedTests: BaseDeploymentDomainServiceTests {

    override func setUp() {
        super.setUp()
        eventPublisher.addFilter(WalletCreationFailed.self)
    }

    func test_whenFailed_thenExits() {
        givenDeployingWallet()
        start()
        system.expect_exit(EXIT_FAILURE)
        wallet.cancel()
        delay()
        system.verify()
    }

}
