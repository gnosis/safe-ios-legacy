//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport

class DeploymentDomainServiceTests: XCTestCase {

    let eventPublisher = EventPublisher()
    let walletRepository = InMemoryWalletRepository()
    let portfolioRepository = InMemorySinglePortfolioRepository()
    let encryptionService = MockEncryptionService()
    let relayService = MockTransactionRelayService1()
    let errorStream = MockErrorStream()
    let deploymentService = DeploymentDomainService()
    var wallet: Wallet!

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: eventPublisher, for: EventPublisher.self)
        DomainRegistry.put(service: walletRepository, for: WalletRepository.self)
        DomainRegistry.put(service: portfolioRepository, for: SinglePortfolioRepository.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
        DomainRegistry.put(service: relayService, for: TransactionRelayDomainService.self)
        DomainRegistry.put(service: errorStream, for: ErrorStream.self)
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
        errorStream.expect_post(TestError.error)
        deploymentService.start()
        errorStream.verify()
    }

    func test_whenCreationTransactionThrows_thenCancelsDeployment() {
        givenDraftWalletWithAllOwners()
        relayService.expect_createSafeCreationTransaction_throw(TestError.error)
        deploymentService.start()
        wallet = walletRepository.findByID(wallet.id)!
        XCTAssertTrue(wallet.state === wallet.newDraftState)
    }

}

// MARK: - Helpers

extension DeploymentDomainServiceTests {

    private func givenDraftWalletWithAllOwners() {
        wallet = Wallet(id: walletRepository.nextID(), owner: Address.deviceAddress)
        wallet.addOwner(Wallet.createOwner(address: Address.extensionAddress.value, role: .browserExtension))
        wallet.addOwner(Wallet.createOwner(address: Address.paperWalletAddress.value, role: .paperWallet))
        walletRepository.save(wallet)
        let portfolio = Portfolio(id: portfolioRepository.nextID())
        portfolio.addWallet(wallet.id)
        portfolioRepository.save(portfolio)
    }

}

// MARK: - Fixtures

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
    }

    func startSafeCreation(address: Address) throws {
        preconditionFailure("not implemented")
    }

    func safeCreationTransactionHash(address: Address) throws -> TransactionHash? {
        preconditionFailure("not implemented")
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
