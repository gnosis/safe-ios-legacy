//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport

class ReplaceBrowserExtensionDomainServiceBaseTestCase: XCTestCase {

    let service = ReplaceBrowserExtensionDomainService()
    let walletRepo = InMemoryWalletRepository()
    let portfolioRepo = InMemorySinglePortfolioRepository()
    let transactionRepo = InMemoryTransactionRepository()

    let mockEncryptionService = MockEncryptionService()
    let accountRepo = InMemoryAccountRepository()
    let mockRelayService = MockTransactionRelayService(averageDelay: 0, maxDeviation: 0)
    let mockProxy = TestableOwnerProxy(Address.testAccount1)

    var ownersWithoutExtension = OwnerList([
        Owner(address: Address.testAccount1, role: .thisDevice),
        Owner(address: Address.testAccount3, role: .paperWallet),
        Owner(address: Address.testAccount4, role: .paperWalletDerived)])

    var ownersWithExtension = OwnerList([
        Owner(address: Address.testAccount1, role: .thisDevice),
        Owner(address: Address.testAccount2, role: .browserExtension),
        Owner(address: Address.testAccount3, role: .paperWallet),
        Owner(address: Address.testAccount4, role: .paperWalletDerived)])

    var noOwners = OwnerList()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: walletRepo, for: WalletRepository.self)
        DomainRegistry.put(service: portfolioRepo, for: SinglePortfolioRepository.self)
        DomainRegistry.put(service: transactionRepo, for: TransactionRepository.self)
        DomainRegistry.put(service: mockEncryptionService, for: EncryptionDomainService.self)
        DomainRegistry.put(service: accountRepo, for: AccountRepository.self)
        DomainRegistry.put(service: mockRelayService, for: TransactionRelayDomainService.self)
        mockProxy.getOwners_result = ownersWithExtension.sortedOwners().map { $0.address }
        service.ownerContractProxy = mockProxy
    }

}



extension ReplaceBrowserExtensionDomainServiceBaseTestCase {

    func loadEOAToMock() {
        mockEncryptionService.deriveExternallyOwnedAccountFromMnemonicResult = .testAccount
        mockEncryptionService.expect_deriveExternallyOwnedAccount(from: .testAccount, at: 1, result: .testAccountAt1)
        mockProxy.getOwners_result = [ExternallyOwnedAccount.testAccountAt1.address,
                                      ExternallyOwnedAccount.testAccount.address]
    }

    func createEstimatedTransaction() -> Transaction {
        setUpWallet()
        let txID = service.createTransaction()
        service.addDummyData(to: txID)
        setNetworkFee(safeGas: 1, dataGas: 1, operationGas: 1, gasPrice: 10)
        _ = try! service.estimateNetworkFee(for: txID)
        return transaction(from: txID)!
    }

    func setNetworkFee(safeGas: Int, dataGas: Int, operationGas: Int, gasPrice: Int) {
        mockRelayService.estimateTransaction_output = .init(safeTxGas: safeGas,
                                                            dataGas: dataGas,
                                                            operationalGas: operationGas,
                                                            gasPrice: gasPrice,
                                                            lastUsedNonce: nil,
                                                            gasToken: Token.Ether.address.value)
    }

    func setUpAccount(transaction tx: Transaction, balance: TokenInt) {
        let account = Account(tokenID: tx.accountID.tokenID, walletID: tx.accountID.walletID, balance: balance)
        accountRepo.save(account)
    }

    @discardableResult
    func setUpWallet() -> Wallet {
        let result = wallet(owners: ownersWithExtension)
        setUpPortfolio(wallet: result)
        return result
    }

    func transaction(from id: TransactionID) -> Transaction? {
        return transactionRepo.findByID(id)
    }

    func wallet(owners: OwnerList) -> Wallet {
        let walletID = walletRepo.nextID()
        let walletAddress = Address.safeAddress
        let wallet = Wallet(id: walletID,
                            state: .readyToUse,
                            owners: owners,
                            address: walletAddress,
                            minimumDeploymentTransactionAmount: nil,
                            creationTransactionHash: nil)
        walletRepo.save(wallet)
        return wallet
    }

    func setUpPortfolio(wallet: Wallet?) {
        let portfolio = Portfolio(id: portfolioRepo.nextID(),
                                  wallets: wallet == nil ? WalletIDList() : WalletIDList([wallet!.id]),
                                  selectedWallet: wallet?.id)
        portfolioRepo.save(portfolio)
    }

}
