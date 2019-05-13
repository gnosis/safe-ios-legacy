//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
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
    let communicationService = CommunicationDomainService()
    let metadataRepo = InMemorySafeContractMetadataRepository(metadata: .testMetadata())
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
        DomainRegistry.put(service: communicationService, for: CommunicationDomainService.self)
        DomainRegistry.put(service: metadataRepo, for: SafeContractMetadataRepository.self)
    }

    func start() {
        deploymentService.start()
        delay()
    }

    var walletAccount: Account {
        let accountID = AccountID(tokenID: Token.Ether.id, walletID: wallet.id)
        let account = DomainRegistry.accountRepository.find(id: accountID)!
        return account
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

    func givenFundedWallet(with amount: TokenInt = 100) {
        givenConfiguredWallet()
        let account = walletAccount
        account.update(newAmount: amount)
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
        wallet = walletRepository.find(id: wallet.id)!
        XCTAssertTrue(wallet.state === wallet.newDraftState, line: line)
    }

    @discardableResult
    internal func expectSafeCreationTransaction() ->
        (request: SafeCreation2Request, response: SafeCreation2Request.Response) {
            let request = SafeCreation2Request(saltNonce: 1,
                                               owners: wallet.allOwners().map { $0.address },
                                               confirmationCount: wallet.confirmationCount,
                                               paymentToken: .zero)
            let response = SafeCreation2Request.Response.testResponse(from: request)
            relayService.expect_createSafeCreationTransaction(request, response)
            return (request, response)
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

extension SafeContractMetadata {

    static func testMetadata() -> SafeContractMetadata {
        let txTypeHash = Data(repeating: 1, count: 32)
        let domainTypeHash = Data(repeating: 2, count: 32)
        let proxyCode = Data(repeating: 3, count: 180)
        return SafeContractMetadata(multiSendContractAddress: .testAccount1,
                                    proxyFactoryAddress: .testAccount2,
                                    safeFunderAddress: .testAccount3,
                                    metadata: [MasterCopyMetadata(address: .testAccount4,
                                                                  version: "1.0.0",
                                                                  txTypeHash: txTypeHash,
                                                                  domainSeparatorHash: domainTypeHash,
                                                                  proxyCode: proxyCode)])
    }

}

extension SafeCreation2Request {

    static func testRequest() -> SafeCreation2Request {
        let owners = [Address.deviceAddress, Address.paperWalletAddress, Address.extensionAddress]
        let paymentToken = Address.zero
        return SafeCreation2Request(saltNonce: 1,
                                    owners: owners,
                                    confirmationCount: 1,
                                    paymentToken: paymentToken)
    }

    static func setupData(payment: TokenInt, receiver: Address = .zero) -> String {
        let request = testRequest()
        return GnosisSafeContractProxy().setup(owners: request.owners.map { Address($0) },
                                               threshold: request.threshold,
                                               to: .zero,
                                               data: Data(),
                                               paymentToken: Address(request.paymentToken),
                                               payment: payment,
                                               paymentReceiver: receiver).toHexString().addHexPrefix()
    }

    func toString() -> String {
        return try! String(data: JSONEncoder().encode(self), encoding: .utf8)!
    }

}

extension SafeCreation2Request.Response {

    static func testResponse(from request: SafeCreation2Request = .testRequest()) -> SafeCreation2Request.Response {
        return testResponse(from: .init(safe: Address.safeAddress.value,
                                        masterCopy: Address.testAccount4.value,
                                        proxyFactory: Address.testAccount2.value,
                                        paymentToken: request.paymentToken,
                                        payment: 100,
                                        paymentReceiver: Address.zero.value,
                                        setupData: SafeCreation2Request.setupData(payment: 100),
                                        gasEstimated: 50,
                                        gasPriceEstimated: 2),
                            request)
    }

    static func testResponse(from response: SafeCreation2Request.Response, _ request: SafeCreation2Request)
        -> SafeCreation2Request.Response {
            let contract = GnosisSafeContractProxy()
            let metadataRepo = DomainRegistry.safeContractMetadataRepository
            let hash: (Data) -> Data = DomainRegistry.encryptionService.hash
            let address = Address("0x" + hash(
                Data([0xff]) +
                    contract.encodeAddress(response.proxyFactoryAddress).suffix(20) +
                    hash(hash(response.setupDataValue) + contract.encodeUInt(TokenInt(request.saltNonce)!)) +
                    hash(metadataRepo.deploymentCode(masterCopyAddress: response.masterCopyAddress)!)
                ).advanced(by: 12).prefix(20).toHexString())
            return .init(safe: address.value,
                         masterCopy: response.masterCopy,
                         proxyFactory: response.proxyFactory,
                         paymentToken: response.paymentToken,
                         payment: response.payment,
                         paymentReceiver: response.paymentReceiver,
                         setupData: response.setupData,
                         gasEstimated: response.gasEstimated,
                         gasPriceEstimated: response.gasPriceEstimated)
    }

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
