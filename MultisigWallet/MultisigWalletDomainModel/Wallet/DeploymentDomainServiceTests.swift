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
    let encryptionService = MockEncryptionService()
    let relayService = MockTransactionRelayService1()
    let errorStream = MockErrorStream()
    let nodeService = MockEthereumNodeService1()
    var deploymentService: DeploymentDomainService!
    let accountRepository = InMemoryAccountRepository()
    var wallet: Wallet!

    override func setUp() {
        super.setUp()
        deploymentService = DeploymentDomainService(.testConfiguration)
        DomainRegistry.put(service: eventPublisher, for: EventPublisher.self)
        DomainRegistry.put(service: walletRepository, for: WalletRepository.self)
        DomainRegistry.put(service: portfolioRepository, for: SinglePortfolioRepository.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
        DomainRegistry.put(service: relayService, for: TransactionRelayDomainService.self)
        DomainRegistry.put(service: errorStream, for: ErrorStream.self)
        DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
        DomainRegistry.put(service: accountRepository, for: AccountRepository.self)
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
        deploymentService.start()
        relayService.verify()
    }

    func test_whenFetchedTransactionData_thenUpdatesAddressAndFee() {
        givenDraftWalletWithAllOwners()
        let response = SafeCreationTransactionRequest.Response.testResponse
        relayService.expect_createSafeCreationTransaction(.testRequest(wallet, encryptionService), response)
        deploymentService.start()
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
        assertDeploymentCancelled()
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
        deploymentService.start()
        nodeService.verify()
        let account = DomainRegistry.accountRepository.find(id: AccountID(Token.Ether.id.id), walletID: wallet.id)!
        XCTAssertEqual(account.balance, 100)
    }

    func test_whenNotEnoughFundsAtFirst_thenRepeatsUntilHasFunds() {
        givenConfiguredWallet()
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 50)
        nodeService.expect_eth_getBalance(account: Address.safeAddress, balance: 100)
        deploymentService.start()
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
        deploymentService.start()
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
        deploymentService.start()
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
        deploymentService.start()
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

    func test_whenFunded_thenWaitsForTransaction() {
        givenDeployingWallet(withoutTransaction: true)
        relayService.expect_safeCreationTransactionHash(address: wallet.address!, hash: nil)
        relayService.expect_safeCreationTransactionHash(address: wallet.address!, hash: TransactionHash.test1)
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: successReceipt)
        deploymentService.start()
        relayService.verify()
        wallet = DomainRegistry.walletRepository.selectedWallet()!
        XCTAssertEqual(wallet.creationTransactionHash, TransactionHash.test1.value)
    }


    func test_whenTransactionKnown_thenWaitsForItsStatus() {
        givenDeployingWallet()
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: successReceipt)
        deploymentService.start()
        relayService.verify()
        nodeService.verify()
        wallet = DomainRegistry.walletRepository.selectedWallet()!
        XCTAssertTrue(wallet.state === wallet.readyToUseState)
    }

    func test_whenTransactionFailed_thenCancels() {
        givenDeployingWallet()
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: failedReceipt)
        deploymentService.start()
        assertDeploymentCancelled()
    }

}

// MARK: - Helpers

extension BaseDeploymentDomainServiceTests {

    func givenDraftWalletWithAllOwners() {
        wallet = Wallet(id: walletRepository.nextID(), owner: Address.deviceAddress)
        wallet.addOwner(Wallet.createOwner(address: Address.extensionAddress.value, role: .browserExtension))
        wallet.addOwner(Wallet.createOwner(address: Address.paperWalletAddress.value, role: .paperWallet))
        walletRepository.save(wallet)
        let portfolio = Portfolio(id: portfolioRepository.nextID())
        portfolio.addWallet(wallet.id)
        portfolioRepository.save(portfolio)
        let account = Account(id: AccountID(Token.Ether.id.id), walletID: wallet.id, balance: 0)
        DomainRegistry.accountRepository.save(account)
    }

    func givenConfiguredWallet() {
        givenDraftWalletWithAllOwners()
        wallet.markReadyToDeploy()
        wallet.startDeployment()
        wallet.changeAddress(Address.safeAddress)
        wallet.updateMinimumTransactionAmount(100)
    }

    func givenFundedWallet() {
        givenConfiguredWallet()
        wallet.proceed()
        let account = DomainRegistry.accountRepository.find(id: AccountID(Token.Ether.id.id), walletID: wallet.id)!
        account.update(newAmount: 100)
        DomainRegistry.accountRepository.save(account)
    }

    func givenDeployingWallet(withoutTransaction: Bool = false) {
        givenFundedWallet()
        wallet.markDeploymentAcceptedByBlockchain()
        if !withoutTransaction {
            wallet.assignCreationTransaction(hash: TransactionHash.test1.value)
        }
        wallet.proceed()
        DomainRegistry.walletRepository.save(wallet)
    }

    func assertThrows(_ error: Error, line: UInt = #line) {
        errorStream.expect_post(error)
        deploymentService.start()
        errorStream.verify(line: line)
    }

    func assertDeploymentCancelled(line: UInt = #line) {
        wallet = walletRepository.findByID(wallet.id)!
        XCTAssertTrue(wallet.state === wallet.newDraftState, line: line)
    }

}

// MARK: - Fixtures

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

// MARK: - Mocks

class MockEventPublisher: EventPublisher {

    private var filteredEventTypes = [String]()

    func addFilter(_ event: Any.Type) {
        filteredEventTypes.append(String(reflecting: event))
    }

    override func publish(_ event: DomainEvent) {
        guard filteredEventTypes.isEmpty || filteredEventTypes.contains(String(reflecting: type(of: event))) else {
            return
        }
        super.publish(event)
    }

}

class MockEthereumNodeService1: EthereumNodeDomainService {

    private var expectations_eth_getBalance = [(account: Address, balance: BigInt)]()
    private var actual_eth_getBalance = [Address]()
    private var eth_getBalance_throws_error: Error?

    func expect_eth_getBalance(account: Address, balance: BigInt) {
        expectations_eth_getBalance.append((account, balance))
    }

    func expect_eth_getBalance_throw(_ error: Error) {
        eth_getBalance_throws_error = error
    }

    func eth_getBalance(account: Address) throws -> BigInt {
        actual_eth_getBalance.append(account)
        if let error = eth_getBalance_throws_error {
            throw error
        }
        return expectations_eth_getBalance[actual_eth_getBalance.count - 1].balance
    }

    func verify(line: UInt = #line) {
        XCTAssertEqual(actual_eth_getBalance.map { $0.value },
                       expectations_eth_getBalance.map { $0.account.value },
                       line: line)
        XCTAssertEqual(actual_eth_getTransactionReceipt.map { $0.value },
                       expected_eth_getTransactionReceipt.map { $0.hash.value },
                       line: line)
    }

    private var expected_eth_getTransactionReceipt = [(hash: TransactionHash, receipt: TransactionReceipt?)]()
    private var actual_eth_getTransactionReceipt = [(TransactionHash)]()
    private var eth_getTransactionReceipt_throws_error: Error?

    func expect_eth_getTransactionReceipt(transaction: TransactionHash, receipt: TransactionReceipt?) {
        expected_eth_getTransactionReceipt.append((transaction, receipt))
    }

    func expect_eth_getTransactionReceipt_throw(_ error: Error) {
        eth_getTransactionReceipt_throws_error = error
    }

    func eth_getTransactionReceipt(transaction: TransactionHash) throws -> TransactionReceipt? {
        actual_eth_getTransactionReceipt.append(transaction)
        if let error = eth_getTransactionReceipt_throws_error {
            throw error
        }
        return expected_eth_getTransactionReceipt[actual_eth_getTransactionReceipt.count - 1].receipt
    }

    func eth_call(to: Address, data: Data) throws -> Data {
        return Data()
    }

}

class MockTransactionRelayService1: TransactionRelayDomainService {

    private var expected_createSafeCreationTransaction:
        [(request: SafeCreationTransactionRequest, response: SafeCreationTransactionRequest.Response)] = []
    private var actual_createSafeCreationTransaction: [SafeCreationTransactionRequest] = []
    private var createSafeCreationTransaction_throws_error: Error?

    func expect_createSafeCreationTransaction(_ request: SafeCreationTransactionRequest,
                                              _ response: SafeCreationTransactionRequest.Response) {
        expected_createSafeCreationTransaction.append((request, response))
    }

    func expect_createSafeCreationTransaction_throw(_ error: Error) {
        createSafeCreationTransaction_throws_error = error
    }

    func createSafeCreationTransaction(request: SafeCreationTransactionRequest) throws ->
        SafeCreationTransactionRequest.Response {
            actual_createSafeCreationTransaction.append(request)
            if let error = createSafeCreationTransaction_throws_error {
                throw error
            }
            return expected_createSafeCreationTransaction[actual_createSafeCreationTransaction.count - 1].response
    }

    func verify(line: UInt = #line) {
        XCTAssertEqual(actual_createSafeCreationTransaction.map { $0.toString() },
                       expected_createSafeCreationTransaction.map { $0.request.toString() },
                       line: line)
        XCTAssertEqual(actual_startSafeCreation.map { $0.value },
                       expected_startSafeCreation.map { $0.value },
                       line: line)
        XCTAssertEqual(actual_safeCreationTransactionHash.map { $0.value },
                       expected_safeCreationTransactionHash.map { $0.address.value },
                       line: line)
    }

    private var expected_startSafeCreation = [Address]()
    private var actual_startSafeCreation = [Address]()
    private var startSafeCreation_throws_error: Error?

    func expect_startSafeCreation_throw(_ error: Error) {
        startSafeCreation_throws_error = error
    }

    func expect_startSafeCreation(address: Address) {
        expected_startSafeCreation.append(address)
    }

    func startSafeCreation(address: Address) throws {
        actual_startSafeCreation.append(address)
        if let error = startSafeCreation_throws_error {
            throw error
        }
    }

    private var expected_safeCreationTransactionHash = [(address: Address, hash: TransactionHash?)]()
    private var actual_safeCreationTransactionHash = [Address]()
    private var safeCreationTransactionHash_throws_error: Error?

    func expect_safeCreationTransactionHash_throw(_ error: Error?) {
        safeCreationTransactionHash_throws_error = error
    }

    func expect_safeCreationTransactionHash(address: Address, hash: TransactionHash?) {
        expected_safeCreationTransactionHash.append((address, hash))
    }

    func safeCreationTransactionHash(address: Address) throws -> TransactionHash? {
        actual_safeCreationTransactionHash.append(address)
        if let error = safeCreationTransactionHash_throws_error {
            throw error
        }
        return expected_safeCreationTransactionHash[actual_safeCreationTransactionHash.count - 1].hash
    }

    func gasPrice() throws -> SafeGasPriceResponse {
        preconditionFailure("not implemented")
    }

    func submitTransaction(request: SubmitTransactionRequest) throws -> SubmitTransactionRequest.Response {
        preconditionFailure("not implemented")
    }

    func estimateTransaction(request: EstimateTransactionRequest) throws -> EstimateTransactionRequest.Response {
        preconditionFailure("not implemented")
    }

}

class MockErrorStream: ErrorStream {

    private var expected_errors = [Error]()
    private var actual_errors = [Error]()

    func expect_post(_ error: Error) {
        expected_errors.append(error)
    }

    override func post(_ error: Error) {
        actual_errors.append(error)
    }

    func verify(line: UInt = #line) {
        XCTAssertEqual(actual_errors.map { $0.localizedDescription },
                       expected_errors.map { $0.localizedDescription },
                       line: line)
    }

}
