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
