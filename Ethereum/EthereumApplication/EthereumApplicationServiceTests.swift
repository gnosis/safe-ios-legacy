//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumApplication
import EthereumDomainModel
import EthereumImplementations
import Common
import CommonTestSupport

class EthereumApplicationServiceTests: EthereumApplicationTestCase {

    let applicationService = EthereumApplicationService()

    func test_address_returnsAddressFromEncryptionService() {
        encryptionService.extensionAddress = "some address"
        XCTAssertEqual(applicationService.address(browserExtensionCode: "any code"),
                       encryptionService.address(browserExtensionCode: "any code"))
    }

    func test_whenGeneratesTwoAccounts_thenTheyAreDifferent() throws {
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        let one = try applicationService.generateExternallyOwnedAccount()
        let two = try applicationService.generateExternallyOwnedAccount()
        XCTAssertNotEqual(one, two)
    }

    func test_whenAccountGenerated_thenItIsPersisted() throws {
        let account = try applicationService.generateExternallyOwnedAccount()
        let saved = try applicationService.findExternallyOwnedAccount(by: account.address)
        XCTAssertEqual(saved, account)
    }

    func test_whenAccountNotFound_thenReturnsNil() {
        XCTAssertNil(try applicationService.findExternallyOwnedAccount(by: "some"))
    }

    func test_whenCreatingSafeTransaction_thenCallsRelayService() throws {
        let output = try applicationService.createSafeCreationTransaction(owners: ["one"], confirmationCount: 1)
        guard let input = relayService.createSafeCreationTransaction_input else {
            XCTFail("Expected call to relay service")
            return
        }
        XCTAssertEqual(input.owners, [Address(value: "one")])
        XCTAssertEqual(input.confirmationCount, 1)
        XCTAssertEqual(input.randomData, Data(repeating: 1, count: 32))
        XCTAssertFalse(output.safe.isEmpty)
        XCTAssertNotEqual(output.payment, 0)
    }

    func test_whenStartingSafeCreation_thenCallsRelayService() throws {
        let output = try applicationService.startSafeCreation(address: "some")
        guard let input = relayService.startSafeCreation_input else {
            XCTFail("Expected call to relay service")
            return
        }
        XCTAssertEqual(input, Address(value: "some"))
        XCTAssertFalse(output.isEmpty)
    }

    func test_whenObservingBalanceAndItChanges_thenCallsObserver() throws {
        var observedBalance: Int?
        var callCount = 0
        try applicationService.observeBalance(address: "address", every: 0.1) { balance in
            if callCount == 3 {
                return true
            }
            observedBalance = balance
            callCount += 1
            return false
        }
        nodeService.eth_getBalance_output = Ether(amount: 2)
        delay(0.1)
        nodeService.eth_getBalance_output = Ether(amount: 1)
        delay(0.1)
        XCTAssertEqual(observedBalance, 1)
        XCTAssertEqual(callCount, 3)
    }

    func test_whenBalanceThrows_thenContinuesObserving() throws {
        var callCount = 0
        try applicationService.observeBalance(address: "address", every: 0.1) { _ in
            if callCount == 3 {
                return true
            }
            callCount += 1
            return false
        }
        nodeService.eth_getBalance_output = Ether(amount: 2)
        delay(0.1)
        nodeService.shouldThrow = true
        nodeService.eth_getBalance_output = Ether(amount: 1)
        delay(0.1)
        nodeService.shouldThrow = false
        delay(0.1)
        XCTAssertEqual(callCount, 3)
    }

    func test_whenTransactionAlreadyCompleted_thenReturnsImmediately() throws {
        nodeService.eth_getTransactionReceipt_output =
            TransactionReceipt(hash: TransactionHash(value: "0xsome"), status: .success)
        var callCount = 0
        try applicationService.observeTransaction(hash: "0xsome", every: 0.1) { _ in
            callCount += 1
        }
        delay(0.2)
        XCTAssertEqual(callCount, 1)
    }

    func test_whenTransactionNotCompleted_thenNotifiesNilOnce() throws {
        var callCount = 0
        try applicationService.observeTransaction(hash: "0xsome", every: 0.1) { _ in
            callCount += 1
        }
        delay(0.2)
        XCTAssertEqual(callCount, 1)
    }

    func test_whenTransactionBecomesCompleted_thenNotifiesAboutIt() throws {
        var callCount = 0
        try applicationService.observeTransaction(hash: "0xsome", every: 0.1) { _ in
            callCount += 1
        }
        delay(0.1)
        nodeService.eth_getTransactionReceipt_output =
            TransactionReceipt(hash: TransactionHash(value: "0xsome"), status: .success)
        delay(0.2)
        XCTAssertEqual(callCount, 2)
    }

    func test_whenServiceThrows_thenDoesNotifyNextTime() throws {
        var callCount = 0
        try applicationService.observeTransaction(hash: "0xsome", every: 0.1) { _ in
            callCount += 1
        }
        delay(0.1)
        nodeService.shouldThrow = true
        delay(0.1)
        nodeService.shouldThrow = false
        nodeService.eth_getTransactionReceipt_output =
            TransactionReceipt(hash: TransactionHash(value: "0xsome"), status: .success)
        delay(0.1)
        XCTAssertEqual(callCount, 2)
    }

}
