//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport
import BigInt

class BaseDeploymentDomainServiceTests: XCTestCase {

    let eventPublisher = MockEventPublisher()
    let walletRepository = InMemoryWalletRepository()
    let portfolioRepository = InMemorySinglePortfolioRepository()
    let encryptionService = MockEncryptionService1()
    let relayService = MockTransactionRelayService1()
    let notificationService = MockNotificationService1()
    let errorStream = MockErrorStream()
    let nodeService = MockEthereumNodeService1()
    var deploymentService: DeploymentDomainService!
    let accountRepository = InMemoryAccountRepository()
    let eoaRepository = InMemoryExternallyOwnedAccountRepository()
    let system = MockSystem()
    let syncService = MockSynchronisationService()
    var wallet: Wallet!

    override func setUp() {
        super.setUp()
        deploymentService = DeploymentDomainService(.testConfiguration)
        deploymentService.responseValidator = MockSafeCreationResponseValidator()
        DomainRegistry.put(service: eventPublisher, for: EventPublisher.self)
        DomainRegistry.put(service: walletRepository, for: WalletRepository.self)
        DomainRegistry.put(service: portfolioRepository, for: SinglePortfolioRepository.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
        DomainRegistry.put(service: relayService, for: TransactionRelayDomainService.self)
        DomainRegistry.put(service: errorStream, for: ErrorStream.self)
        DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
        DomainRegistry.put(service: accountRepository, for: AccountRepository.self)
        DomainRegistry.put(service: notificationService, for: NotificationDomainService.self)
        DomainRegistry.put(service: eoaRepository, for: ExternallyOwnedAccountRepository.self)
        DomainRegistry.put(service: system, for: System.self)
        DomainRegistry.put(service: syncService, for: SynchronisationDomainService.self)
    }

     func start() {
        deploymentService.start()
        delay()
    }

}

class DeploymentServiceEventSubscriptionTests: BaseDeploymentDomainServiceTests {

    func test_whenStartsTwice_thenDoesNotDuplicateEventHandling() {
        eventPublisher.addFilter(DeploymentStarted.self)

        givenDraftWalletWithAllOwners()
        relayService.expect_createSafeCreationTransaction(.testRequest(wallet, encryptionService), .testResponse)
        start()

        portfolioRepository.remove(portfolioRepository.portfolio()!)
        walletRepository.remove(wallet)
        relayService.expect_createSafeCreationTransaction(.testRequest(wallet, encryptionService), .testResponse)
        givenDraftWalletWithAllOwners()
        start()

        relayService.verify()
    }

}

class DeployingWalletTests: BaseDeploymentDomainServiceTests {

    override func setUp() {
        super.setUp()
        eventPublisher.addFilter(DeploymentStarted.self)
    }

    func test_whenInDraft_thenFetchesCreationTransactionData() {
        givenDraftWalletWithAllOwners()
        relayService.expect_createSafeCreationTransaction(.testRequest(wallet, encryptionService), .testResponse)
        start()
        relayService.verify()
    }

    func test_whenFetchedTransactionData_thenUpdatesAddressAndFee() {
        givenDraftWalletWithAllOwners()
        let response = SafeCreationTransactionRequest.Response.testResponse
        relayService.expect_createSafeCreationTransaction(.testRequest(wallet, encryptionService), response)
        start()
        wallet = walletRepository.findByID(wallet.id)!
        XCTAssertEqual(wallet.address, response.walletAddress)
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
        givenDraftWalletWithAllOwners()
        relayService.expect_createSafeCreationTransaction(.testRequest(wallet, encryptionService), .testResponse)
        start()
        XCTAssertTrue(wallet.state === wallet.notEnoughFundsState)
    }

}

class ConfiguredWalletTests: BaseDeploymentDomainServiceTests {

    override func setUp() {
        super.setUp()
        eventPublisher.addFilter(WalletConfigured.self)
    }

    func test_whenWalletConfigured_thenObservesBalance() {
        givenConfiguredWallet()
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 100)
        start()
        nodeService.verify()
        let accountID = AccountID(tokenID: Token.Ether.id, walletID: wallet.id)
        let account = DomainRegistry.accountRepository.find(id: accountID)!
        XCTAssertEqual(account.balance, 100)
    }

    func test_whenNotEnoughFundsAtFirst_thenRepeatsUntilHasFunds() {
        givenConfiguredWallet()
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 50)
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 100)
        start()
        nodeService.verify()
    }

    func test_whenObservingBalanceFails_thenErrorPosted() {
        givenConfiguredWallet()
        nodeService.expect_eth_getBalance_throw(TestError.error)
        assertThrows(TestError.error)
    }

    func test_whenObservingBalanceFails_thenCancels() {
        givenConfiguredWallet()
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

    let successReceipt = TransactionReceipt(hash: TransactionHash.test1, status: .success)
    let failedReceipt = TransactionReceipt(hash: TransactionHash.test1, status: .failed)

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
        assertDeploymentCancelled()
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

// MARK: - Helpers

extension BaseDeploymentDomainServiceTests {

    func givenDraftWalletWithAllOwners() {
        wallet = Wallet(id: walletRepository.nextID(), owner: Address.deviceAddress)
        wallet.addOwner(Wallet.createOwner(address: Address.extensionAddress.value, role: .browserExtension))
        wallet.addOwner(Wallet.createOwner(address: Address.paperWalletAddress.value, role: .paperWallet))
        wallet.addOwner(Wallet.createOwner(address: Address.testAccount1.value, role: .paperWalletDerived))
        wallet.changeConfirmationCount(2)
        let account = Account(tokenID: Token.Ether.id, walletID: wallet.id)
        walletRepository.save(wallet)
        let portfolio = Portfolio(id: portfolioRepository.nextID())
        portfolio.addWallet(wallet.id)
        portfolioRepository.save(portfolio)
        DomainRegistry.accountRepository.save(account)
    }

    func givenConfiguredWallet() {
        givenDraftWalletWithAllOwners()
        wallet.proceed()
        wallet.changeAddress(Address.safeAddress)
        wallet.updateMinimumTransactionAmount(100)
        wallet.proceed()
    }

    func givenFundedWallet() {
        givenConfiguredWallet()
        let accountID = AccountID(tokenID: Token.Ether.id, walletID: wallet.id)
        let account = DomainRegistry.accountRepository.find(id: accountID)!
        account.update(newAmount: 100)
        DomainRegistry.accountRepository.save(account)
        wallet.proceed()
    }

    func givenDeployingWallet(withoutTransaction: Bool = false) {
        givenFundedWallet()
        wallet.proceed()
        if !withoutTransaction {
            wallet.assignCreationTransaction(hash: TransactionHash.test1.value)
        }
        DomainRegistry.walletRepository.save(wallet)
    }

    func givenCreatedWallet() {
        givenDeployingWallet()
        wallet.proceed()
        walletRepository.save(wallet)
    }

    func expectSafeCreatedNotification() {
        eoaRepository.save(.createTestAccount(wallet,
                                        role: .thisDevice,
                                        privateKey: .testPrivateKey,
                                        publicKey: .testPublicKey))
        let message = "safeCreated"
        let request = SendNotificationRequest(message: message,
                                              to: wallet.owner(role: .browserExtension)!.address.value,
                                              from: .testSignature)
        encryptionService.expect_sign(message: "GNO" + message,
                                      privateKey: .testPrivateKey,
                                      signature: .testSignature)
        notificationService.expect_safeCreatedMessage(at: Address.safeAddress.value, message: message)
        notificationService.expect_send(notificationRequest: request)
    }

    func givenCreatedWalletWithNotifiedExtension() {
        givenDeployingWallet()
        expectSafeCreatedNotification()
    }

    func assertThrows(_ error: Error, line: UInt = #line) {
        errorStream.expect_post(error)
        start()
        XCTAssertTrue(errorStream.verify(), line: line)
    }

    func assertDeploymentCancelled(line: UInt = #line) {
        wallet = walletRepository.findByID(wallet.id)!
        XCTAssertTrue(wallet.state === wallet.newDraftState, line: line)
    }

}

extension SendNotificationRequest {

    func toString() -> String {
        return try! String(data: JSONEncoder().encode(self), encoding: .utf8)!
    }

}

// MARK: - Fixtures

extension NSError {
    static let urlError = NSError(domain: NSURLErrorDomain, code: 1, userInfo: nil)
}

extension DeploymentDomainServiceConfiguration {
    static let testConfiguration = DeploymentDomainServiceConfiguration(balance: .testParameters,
                                                                        deploymentStatus: .testParameters,
                                                                        transactionStatus: .testParameters)
}

extension DeploymentDomainServiceConfiguration.Parameters {
    static let testParameters = DeploymentDomainServiceConfiguration.Parameters(repeatDelay: 0,
                                                                                retryAttempts: 3,
                                                                                retryDelay: 0)
}

extension SafeCreationTransactionRequest {

    static func testRequest(_ wallet: Wallet, _ encryptionService: EncryptionDomainService) ->
        SafeCreationTransactionRequest {
            return SafeCreationTransactionRequest(owners: wallet.allOwners().map { $0.address },
                                                  confirmationCount: wallet.confirmationCount,
                                                  ecdsaRandomS: encryptionService.ecdsaRandomS())
    }

    func toString() -> String {
        return try! String(data: JSONEncoder().encode(self), encoding: .utf8)!
    }

}

extension SafeCreationTransactionRequest.Response {
    static let testResponse = SafeCreationTransactionRequest.Response(signature: .testSignature,
                                                                      tx: .testTransaction,
                                                                      safe: Address.safeAddress.value,
                                                                      payment: "100")
}


extension SafeCreationTransactionRequest.Response.Signature {
    static let testSignature = SafeCreationTransactionRequest.Response.Signature(r: "0", s: "0", v: "27")
}

extension SafeCreationTransactionRequest.Response.Transaction {
    static let testTransaction = SafeCreationTransactionRequest.Response.Transaction(from: Address.testAccount1.value,
                                                                                     value: 100,
                                                                                     data: "0x01",
                                                                                     gas: "100",
                                                                                     gasPrice: "100",
                                                                                     nonce: 0)
}

extension ExternallyOwnedAccount {
    static func createTestAccount(_ wallet: Wallet, role: OwnerRole, privateKey: PrivateKey, publicKey: PublicKey)
        -> ExternallyOwnedAccount {
            return ExternallyOwnedAccount(address: wallet.owner(role: role)!.address,
                                          mnemonic: Mnemonic(words: ["one", "two"]),
                                          privateKey: privateKey,
                                          publicKey: publicKey)
    }
}

extension PrivateKey {
    static let testPrivateKey = PrivateKey(data: Data(repeating: 3, count: 32))
}

extension PublicKey {
    static let testPublicKey = PublicKey(data: Data(repeating: 5, count: 32))
}

extension EthSignature {
    static let testSignature = EthSignature(r: "1", s: "2", v: 27)
}
