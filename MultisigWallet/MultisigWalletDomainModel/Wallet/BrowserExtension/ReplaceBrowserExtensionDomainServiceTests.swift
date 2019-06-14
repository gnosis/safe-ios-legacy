//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport

class ReplaceBrowserExtensionDomainServiceTests: ReplaceBrowserExtensionDomainServiceBaseTestCase {

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
        XCTAssertEqual(tx.data, service.dummyTransactionData())
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

        let actualData = service.realTransactionData(with: newAddress.value)!

        XCTAssertEqual(actualData,
                       expectedData,
                       "Actual: \(actualData.toHexString()) Expected: \(expectedData.toHexString())")
    }

    func test_whenUpdatesTransaction_thenPutsNewData() {
        setUpWallet()
        let txID = service.createTransaction()
        service.update(transaction: txID, newOwnerAddress: Address.testAccount4.value)
        let tx = transaction(from: txID)!
        XCTAssertEqual(tx.data, service.realTransactionData(with: Address.testAccount4.value))
    }

    func test_whenHasExtensionDataInside_thenCanExtractNewOwnerAddress() {
        setUpWallet()
        let txID = service.createTransaction()
        service.update(transaction: txID, newOwnerAddress: Address.testAccount4.value)
        XCTAssertEqual(service.newOwnerAddress(from: txID), Address.testAccount4.value.lowercased())
    }

    func test_whenEstimatingTransaction_thenSetsNonce() {
        setUpWallet()
        let tx = createEstimatedTransaction()
        XCTAssertNotNil(tx.nonce)
    }

}
