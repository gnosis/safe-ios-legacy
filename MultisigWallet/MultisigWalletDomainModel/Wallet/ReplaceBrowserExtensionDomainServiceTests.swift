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
        XCTAssertEqual(tx.operation, .call)
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

    func test_whenEstimatingNetworkFees_thenDoesSo() {
        let expectedFee = TokenAmount.ether(30)
        setNetworkFee(safeGas: 1, dataGas: 1, operationGas: 1, gasPrice: 10)
        setUpWallet()
        let txID = service.createTransaction()
        service.addDummyData(to: txID)
        let actualFee = try! service.estimateNetworkFee(for: txID)
        XCTAssertEqual(actualFee, expectedFee)
    }

    func test_whenAccountBalanceQueried_thenReturnsIt() {
        setUpWallet()
        let tx = transaction(from: service.createTransaction())!
        let expectedBalance: TokenInt = 123
        setUpAccount(transaction: tx, balance: expectedBalance)
        XCTAssertEqual(service.accountBalance(for: tx.id), TokenAmount.ether(expectedBalance))
    }

    func test_whenResultingBalanceCalculated_thenSummedWithChangedAmount() {
        setUpWallet()
        let tx = transaction(from: service.createTransaction())!
        setUpAccount(transaction: tx, balance: 0)
        XCTAssertEqual(service.resultingBalance(for: tx.id, change: TokenAmount.ether(-1)), TokenAmount.ether(-1))
    }

    func test_whenValidatingTransaction_thenThrowsOnBalanceError() {
        setUpWallet()
        let tx = transaction(from: service.createTransaction())!
        setUpAccount(transaction: tx, balance: 0)
        service.addDummyData(to: tx.id)
        setNetworkFee(safeGas: 1, dataGas: 1, operationGas: 1, gasPrice: 10)
        _ = try! service.estimateNetworkFee(for: tx.id)
        XCTAssertThrowsError(try service.validate(transactionID: tx.id))
    }

    func test_whenValidating_thenThrowsOnInexistingExtension() {
        setUpPortfolio(wallet: wallet(owners: ownersWithoutExtension))
        let tx = transaction(from: service.createTransaction())!
        setUpAccount(transaction: tx, balance: 100)
        service.addDummyData(to: tx.id)
        setNetworkFee(safeGas: 1, dataGas: 1, operationGas: 1, gasPrice: 10)
        _ = try! service.estimateNetworkFee(for: tx.id)
        XCTAssertThrowsError(try service.validate(transactionID: tx.id))
    }

    func test_whenCreatingSwapOwnerData_thenReturnsCorrectData() {
        let wallet = setUpWallet()
        let newAddress = Address.testAccount4
        let prevAddress = Address.testAccount1
        let oldAddress = wallet.owner(role: .browserExtension)!.address
        mockProxy.getOwners_result = [prevAddress, oldAddress]
        let expectedData = mockProxy.swapOwner(prevOwner: prevAddress, old: oldAddress, new: newAddress)

        let actualData = service.swapOwnerData(with: newAddress.value)!

        XCTAssertEqual(actualData,
                       expectedData,
                       "Actual: \(actualData.toHexString()) Expected: \(expectedData.toHexString())")
    }

    func test_whenUpdatesTransaction_thenPutsNewData() {
        setUpWallet()
        let txID = service.createTransaction()
        service.update(transaction: txID, newOwnerAddress: Address.testAccount4.value)
        let tx = transaction(from: txID)!
        XCTAssertEqual(tx.data, service.swapOwnerData(with: Address.testAccount4.value))
    }

    func test_whenHasExtensionDataInside_thenCanExtractNewOwnerAddress() {
        setUpWallet()
        let txID = service.createTransaction()
        service.update(transaction: txID, newOwnerAddress: Address.testAccount4.value)
        XCTAssertEqual(service.newOwnerAddress(from: txID), Address.testAccount4.value.lowercased())
    }

    func test_whenNewOnwerAddressIsOwner_thenThrows() {
        setUpWallet()
        _ = service.createTransaction()
        let existingOwner = Address.testAccount1
        mockProxy.getOwners_result = [existingOwner]
        XCTAssertThrowsError(try service.validateNewOwnerAddress(existingOwner.value))
    }

    func test_whenEstimatingTransaction_thenSetsNonce() {
        setUpWallet()
        let tx = createEstimatedTransaction()
        XCTAssertNotNil(tx.nonce)
    }

    func test_whenSigningTransaction_thenSetsRequiredFields() throws {
        loadEOAToMock()
        let expectedHash = Data(repeating: 1, count: 32)
        mockEncryptionService.hash_of_tx_output = expectedHash
        var tx = createEstimatedTransaction()

        XCTAssertNotNil(tx.sender)
        XCTAssertNil(tx.hash)
        XCTAssertEqual(tx.status, .draft)

        try service.sign(transactionID: tx.id, with: "Phrase")
        tx = transaction(from: tx.id)!
        XCTAssertEqual(tx.hash, expectedHash)
        XCTAssertEqual(tx.status, .signing)
    }

    func test_whenSigningWithPhrase_thenDerivesEOAFromPhrase() {
        loadEOAToMock()
        let actual = service.signingEOA(from: "phrase")!
        let expected = (ExternallyOwnedAccount.testAccount, ExternallyOwnedAccount.testAccountAt1)
        XCTAssertEqual(actual.primary, expected.0)
        XCTAssertEqual(actual.derived, expected.1)
    }

    func test_whenSigning_thenSignsWithBothKeys() throws {
        loadEOAToMock()
        let signatureData = Data(repeating: 3, count: 32)
        var tx = createEstimatedTransaction()
        mockEncryptionService.signTransactionPrivateKey_output = signatureData
        try service.sign(transactionID: tx.id, with: "Phrase")
        tx = transaction(from: tx.id)!
        XCTAssertEqual(tx.signatures, [Signature(data: signatureData,
                                                 address: ExternallyOwnedAccount.testAccount.address),
                                       Signature(data: signatureData,
                                                 address: ExternallyOwnedAccount.testAccountAt1.address)])
    }

    func test_whenPhraseIncorrect_thenThrows() {
        let tx = createEstimatedTransaction()
        mockEncryptionService.deriveExternallyOwnedAccountFromMnemonicResult = nil
        XCTAssertThrowsError(try service.sign(transactionID: tx.id, with: "Phrase"))
    }

    func test_whenKeysAreNotOwners_thenThrows() {
        let tx = createEstimatedTransaction()

        // not found
        loadEOAToMock()
        mockProxy.getOwners_result = []
        XCTAssertThrowsError(try service.sign(transactionID: tx.id, with: "Phrase"))

        // 1 of 2
        loadEOAToMock()
        mockProxy.getOwners_result = [ExternallyOwnedAccount.testAccount.address]
        XCTAssertThrowsError(try service.sign(transactionID: tx.id, with: "Phrase"))

        loadEOAToMock()
        mockProxy.getOwners_result = [ExternallyOwnedAccount.testAccountAt1.address]
        XCTAssertThrowsError(try service.sign(transactionID: tx.id, with: "Phrase"))

        // lowercase / uppercase
        loadEOAToMock()
        mockProxy.getOwners_result = [ExternallyOwnedAccount.testAccountAt1.address.value.lowercased(),
                                      ExternallyOwnedAccount.testAccount.address.value.lowercased()].map(Address.init)
        XCTAssertNoThrow(try service.sign(transactionID: tx.id, with: "Phrase"))
    }

}

class TestableOwnerProxy: SafeOwnerManagerContractProxy {

    var getOwners_result = [Address]()

    override func getOwners() throws -> [Address] {
        return getOwners_result
    }
}

extension ReplaceBrowserExtensionDomainServiceTests {

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
