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

    func test_whenAccountRemoved_thenCannotBeFound() throws {
        let account = try applicationService.generateExternallyOwnedAccount()
        try applicationService.removeExternallyOwnedAccount(address: account.address)
        XCTAssertNil(try applicationService.findExternallyOwnedAccount(by: account.address))
    }

    func test_whenAccountNotFound_thenReturnsNil() {
        XCTAssertNil(try applicationService.findExternallyOwnedAccount(by: "some"))
    }

    func test_whenCreatingSafeTransaction_thenCallsRelayService() throws {
        _ = try applicationService.createSafeCreationTransaction(owners: ["one"], confirmationCount: 1)
        XCTAssertNotNil(relayService.createSafeCreationTransaction_input)
    }

    func test_whenStartingSafeCreation_thenCallsRelayService() throws {
        try applicationService.startSafeCreation(address: "some")
        guard let input = relayService.startSafeCreation_input else {
            XCTFail("Expected call to relay service")
            return
        }
        XCTAssertEqual(input, Address(value: "some"))
    }

    func test_whenObservingBalanceAndItChanges_thenCallsObserver() throws {
        var observedBalance: Int?
        var callCount = 0
        DispatchQueue.global().async {
            try? self.applicationService.observeChangesInBalance(address: "address", every: 0.1) { balance in
                if callCount == 3 {
                    return true
                }
                observedBalance = balance
                callCount += 1
                return false
            }
        }
        delay(0.1)
        nodeService.eth_getBalance_output = Ether(amount: 2)
        delay(0.1)
        nodeService.eth_getBalance_output = Ether(amount: 2)
        delay(0.1)
        nodeService.eth_getBalance_output = Ether(amount: 1)
        delay(0.1)
        XCTAssertEqual(observedBalance, 1)
        XCTAssertEqual(callCount, 3)
    }

    func test_whenBalanceThrows_thenContinuesObserving() throws {
        var callCount = 0
        DispatchQueue.global().async {
            try? self.applicationService.observeChangesInBalance(address: "address", every: 0.1) { _ in
                if callCount == 3 {
                    return true
                }
                callCount += 1
                return false
            }
        }
        delay(0.1)
        nodeService.eth_getBalance_output = Ether(amount: 2)
        delay(0.1)
        nodeService.shouldThrow = true
        nodeService.eth_getBalance_output = Ether(amount: 1)
        delay(0.1)
        nodeService.shouldThrow = false
        delay(0.1)
        XCTAssertEqual(callCount, 3)
    }

    func test_whenSignsMessage_thenSignatureIsCorrect() throws {
        let pk = PrivateKey(data: Data(repeating: 1, count: 32))
        try eoaRepository.save(ExternallyOwnedAccount(
            address: Address(value: "signer"),
            mnemonic: Mnemonic(words: ["test"]),
            privateKey: pk,
            publicKey: PublicKey(data: Data())))
        encryptionService.sign_output = ("r", "s", 1)
        let (r, s, v) = try applicationService.sign(message: "Gnosis", by: "signer")
        XCTAssertEqual(r, "r")
        XCTAssertEqual(s, "s")
        XCTAssertEqual(v, 1)
        XCTAssertEqual(encryptionService.sign_input?.message, "Gnosis")
        XCTAssertEqual(encryptionService.sign_input?.privateKey, pk)
    }

    func test_whenSignMessageForUnknownAddress_thenThrows() throws {
        XCTAssertThrowsError(try applicationService.sign(message: "Gnosis", by: "signer"))
    }

}
