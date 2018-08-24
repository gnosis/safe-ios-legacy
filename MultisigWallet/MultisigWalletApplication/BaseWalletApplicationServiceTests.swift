//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletImplementations
import MultisigWalletDomainModel
import Common


class BaseWalletApplicationServiceTests: XCTestCase {

    let walletRepository = InMemoryWalletRepository()
    let portfolioRepository = InMemorySinglePortfolioRepository()
    let accountRepository = InMemoryAccountRepository()
    let ethereumService = MockEthereumApplicationService()
    let service = WalletApplicationService()
    let notificationService = MockNotificationService()
    let tokensService = MockPushTokensDomainService()
    let transactionRepository = InMemoryTransactionRepository()
    let relayService = MockTransactionRelayService(averageDelay: 0, maxDeviation: 0)
    let encryptionService = MockEncryptionService()
    let eoaRepo = InMemoryExternallyOwnedAccountRepository()
    let syncService = SynchronisationService(retryInterval: 0.1)
    let tokenItemsRepository = InMemoryTokenListItemRepository()
    let tokenItemsService = MockTokenListService()

    let eventPublisher = MockEventPublisher()
    var eventRelay: MockEventRelay!
    let deploymentService = MockDeploymentDomainService()
    let errorStream = MockErrorStream()

    enum Error: String, LocalizedError, Hashable {
        case walletNotFound
        case accountNotFound
    }

    override func setUp() {
        super.setUp()
        eventRelay = MockEventRelay(publisher: eventPublisher)

        DomainRegistry.put(service: transactionRepository, for: TransactionRepository.self)
        DomainRegistry.put(service: eoaRepo, for: ExternallyOwnedAccountRepository.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)

        DomainRegistry.put(service: deploymentService, for: DeploymentDomainService.self)
        DomainRegistry.put(service: eventPublisher, for: EventPublisher.self)
        DomainRegistry.put(service: errorStream, for: ErrorStream.self)

        ApplicationServiceRegistry.put(service: eventRelay, for: EventRelay.self)

        DomainRegistry.put(service: walletRepository, for: WalletRepository.self)
        DomainRegistry.put(service: portfolioRepository, for: SinglePortfolioRepository.self)
        DomainRegistry.put(service: accountRepository, for: AccountRepository.self)
        DomainRegistry.put(service: notificationService, for: NotificationDomainService.self)
        DomainRegistry.put(service: tokensService, for: PushTokensDomainService.self)
        ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
        ApplicationServiceRegistry.put(service: ethereumService, for: EthereumApplicationService.self)
        DomainRegistry.put(service: relayService, for: TransactionRelayDomainService.self)
        DomainRegistry.put(service: tokenItemsRepository, for: TokenListItemRepository.self)
        DomainRegistry.put(service: tokenItemsService, for: TokenListDomainService.self)

        ethereumService.createSafeCreationTransaction_output =
            SafeCreationTransactionData(safe: Address.safeAddress.value, payment: 100)
        ethereumService.prepareToGenerateExternallyOwnedAccount(address: Address.deviceAddress.value,
                                                                mnemonic: ["a", "b"])
    }

    class MySubscriber: EventSubscriber {
        func notify() {}
    }

    func givenReadyToUseWallet() {
        try! givenReadyToDeployWallet()
        let wallet = walletRepository.selectedWallet()!
        wallet.state = wallet.deployingState
        wallet.changeAddress(Address.safeAddress)
        wallet.updateMinimumTransactionAmount(100)
        wallet.state = wallet.readyToUseState
        walletRepository.save(wallet)
        service.update(account: Token.Ether.id, newBalance: 1)
        service.update(account: Token.Ether.id, newBalance: 100)
    }

    func givenDraftTransaction() -> Transaction {
        ethereumService.nonce_output = 3
        givenReadyToUseWallet()
        let txID = service.createNewDraftTransaction()
        service.updateTransaction(txID, amount: 100, recipient: Address.testAccount1.value)
        return transactionRepository.findByID(TransactionID(txID))!
    }

    func prepareTransactionForSigning(basedOn message: TransactionDecisionMessage)
        -> (Transaction, Data, Address) {

            givenReadyToUseWallet()

            let extensionAddress = Address(service.ownerAddress(of: .browserExtension)!)
            let signatureData = Data(repeating: 1, count: 32)

            let deviceAddress = Address(service.ownerAddress(of: .thisDevice)!)
            eoaRepo.save(ExternallyOwnedAccount(address: deviceAddress,
                                                mnemonic: Mnemonic(words: ["a", "b"]),
                                                privateKey: PrivateKey(data: Data()),
                                                publicKey: PublicKey(data: Data())))

            encryptionService.addressFromHashSignature_output = extensionAddress.value.lowercased()
            encryptionService.dataFromSignature_output = signatureData

            let walletID = WalletID()
            let transaction = Transaction(id: TransactionID(),
                                          type: .transfer,
                                          walletID: walletID,
                                          accountID: AccountID(tokenID: Token.Ether.id, walletID: walletID))
            transaction.change(hash: message.hash)
                .change(sender: Address.safeAddress)
                .change(recipient: Address.testAccount1)
                .change(amount: TokenAmount.ether(1))
                .change(fee: TokenAmount.ether(1))
                .change(operation: .call)
                .change(feeEstimate:
                    TransactionFeeEstimate(gas: 10,
                                           dataGas: 10,
                                           gasPrice:
                        TokenAmount(amount: 10, token: Token.Ether)))
                .change(nonce: "0")
                .change(status: .signing)
            transactionRepository.save(transaction)
            return (transaction, signatureData, extensionAddress)
    }

    func addAllOwners() {
        service.addOwner(address: Address.extensionAddress.value, type: .browserExtension)
        service.addOwner(address: Address.paperWalletAddress.value, type: .paperWallet)
    }

    func createPortfolio() {
        portfolioRepository.save(Portfolio(id: portfolioRepository.nextID()))
    }

    var selectedWallet: Wallet {
        return DomainRegistry.walletRepository.selectedWallet()!
    }

    func findAccount(_ tokenID: String) throws -> Account {
        let wallet = selectedWallet
        let accountID = AccountID(tokenID: TokenID(tokenID), walletID: wallet.id)
        guard let account = accountRepository.find(id: accountID, walletID: wallet.id) else {
            throw Error.accountNotFound
        }
        return account
    }

    func givenDraftWallet() {
        createPortfolio()
        service.createNewDraftWallet()
    }

    func givenReadyToDeployWallet(line: UInt = #line) throws {
        givenDraftWallet()
        addAllOwners()
    }
}
