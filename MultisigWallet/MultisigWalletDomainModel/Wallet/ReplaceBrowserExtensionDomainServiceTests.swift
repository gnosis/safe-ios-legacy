//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport

class ReplaceBrowserExtensionDomainServiceTests: XCTestCase {

    let service = ReplaceBrowserExtensionDomainService()
    let walletRepo = InMemoryWalletRepository()
    let portfolioRepo = InMemorySinglePortfolioRepository()
    let transactionRepo = InMemoryTransactionRepository()

    let mockEncryptionService = MockEncryptionService()

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
    }

    func test_whenSafeExistsAndExtensionSetUp_thenAvailable() {
        setUpPortfolio(wallet: wallet(owners: ownersWithExtension))
        XCTAssertTrue(service.isAvailable)
    }

    func test_whenConditionsNotMet_thenNotAvailalbe() {
        XCTAssertFalse(service.isAvailable, "No portfolio, no wallet")
    }

    func test_whenPortfolioWihtoutWalelts_thenNotAvailable() {
        setUpPortfolio(wallet: nil)
        XCTAssertFalse(service.isAvailable, "Portfolio, no wallets")
    }

    func test_whenPortfolioWalletWithoutOwners_thenNotAvailable() {
        setUpPortfolio(wallet: wallet(owners: noOwners))
        XCTAssertFalse(service.isAvailable, "Portfolio, wallet, no owners")
    }

    func test_whenPortfolioWalletOwnersNoExtension_thenNotAvailable() {
        setUpPortfolio(wallet: wallet(owners: ownersWithoutExtension))
        XCTAssertFalse(service.isAvailable, "No extension")
    }

    func test_whenCreatingTransaction_thenHasBasicFieldsSet() {
        let wallet = setUpWallet()
        let tx = transaction(from: service.createTransaction())!
        XCTAssertEqual(tx.sender, wallet.address)
        XCTAssertEqual(tx.accountID.tokenID, Token.Ether.id)
        XCTAssertEqual(tx.accountID.walletID, wallet.id)
        XCTAssertEqual(tx.walletID, wallet.id)
        XCTAssertEqual(tx.amount, TokenAmount.ether(0))
        XCTAssertEqual(tx.type, .replaceBrowserExtension)
    }

    func test_whenDeletingTransaction_thenRemovedFromRepository() {
        setUpWallet()
        let txID = service.createTransaction()
        service.deleteTransaction(id: txID)
        XCTAssertNil(transaction(from: txID))
    }

    func test_whenAddingDummyData_thenCreatesDummyTransactionFields() {
        let wallet = setUpWallet()
        let txID = service.createTransaction()
        service.addDummyData(to: txID)
        let tx = transaction(from: txID)!
        XCTAssertEqual(tx.operation, .delegateCall)
        XCTAssertEqual(tx.data, service.dummySwapData())
        XCTAssertEqual(tx.recipient, wallet.address!)
    }

    func test_whenRemovesDummyData_thenRemovesFields() {
        setUpWallet()
        let txID = service.createTransaction()
        service.addDummyData(to: txID)
        service.removeDummyData(from: txID)
        let tx = transaction(from: txID)!
        XCTAssertNil(tx.operation)
        XCTAssertNil(tx.data)
        XCTAssertNil(tx.recipient)
    }

}

class TestableOwnerProxy: SafeOwnerManagerContractProxy {

    var getOwners_result = [Address]()

    override func getOwners() throws -> [Address] {
        return getOwners_result
    }
}

extension ReplaceBrowserExtensionDomainServiceTests {

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
