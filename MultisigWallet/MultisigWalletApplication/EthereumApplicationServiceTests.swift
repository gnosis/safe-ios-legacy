//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import MultisigWalletImplementations
import Common
import CommonTestSupport
import BigInt

class EthereumApplicationServiceTests: EthereumApplicationTestCase {

    let applicationService = EthereumApplicationService()

    func test_address_returnsAddressFromEncryptionService() {
        encryptionService.extensionAddress = "some address"
        XCTAssertEqual(applicationService.address(browserExtensionCode: "any code"),
                       encryptionService.address(browserExtensionCode: "any code"))
    }

    func test_whenGeneratesTwoAccounts_thenTheyAreDifferent() {
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        let one: ExternallyOwnedAccountData = applicationService.generateExternallyOwnedAccount()
        let two: ExternallyOwnedAccountData = applicationService.generateExternallyOwnedAccount()
        XCTAssertNotEqual(one, two)
    }

    func test_whenAccountGenerated_thenItIsPersisted() {
        let account: ExternallyOwnedAccountData = applicationService.generateExternallyOwnedAccount()
        let saved = applicationService.findExternallyOwnedAccount(by: account.address)
        XCTAssertEqual(saved, account)
    }

    func test_whenAccountRemoved_thenCannotBeFound() {
        let account: ExternallyOwnedAccountData = applicationService.generateExternallyOwnedAccount()
        applicationService.removeExternallyOwnedAccount(address: account.address)
        XCTAssertNil(applicationService.findExternallyOwnedAccount(by: account.address))
    }

    func test_whenAccountNotFound_thenReturnsNil() {
        XCTAssertNil(applicationService.findExternallyOwnedAccount(by: "some"))
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

    func test_whenObservingBalanceAndItChanges_thenCallsObserver() {
        var observedBalance: BigInt?
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
        nodeService.eth_getBalance_output = BigInt(2)
        delay(0.1)
        nodeService.eth_getBalance_output = BigInt(2)
        delay(0.1)
        nodeService.eth_getBalance_output = BigInt(1)
        delay(0.1)
        XCTAssertEqual(observedBalance, 1)
        XCTAssertEqual(callCount, 3)
    }

    func test_whenBalanceThrows_thenContinuesObserving() {
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
        nodeService.eth_getBalance_output = BigInt(2)
        delay(0.1)
        nodeService.shouldThrow = true
        nodeService.eth_getBalance_output = BigInt(1)
        delay(0.1)
        nodeService.shouldThrow = false
        delay(0.1)
        XCTAssertEqual(callCount, 3)
    }

    func test_whenSignsMessage_thenSignatureIsCorrect() throws {
        let pk = PrivateKey(data: Data(repeating: 1, count: 32))
        eoaRepository.save(ExternallyOwnedAccount(
            address: Address(value: "signer"),
            mnemonic: Mnemonic(words: ["test"]),
            privateKey: pk,
            publicKey: PublicKey(data: Data())))
        encryptionService.sign_output = EthSignature(r: "r", s: "s", v: 1)
        let (r, s, v) = try applicationService.sign(message: "Gnosis", by: "signer")
        XCTAssertEqual(r, "r")
        XCTAssertEqual(s, "s")
        XCTAssertEqual(v, 1)
        XCTAssertEqual(encryptionService.sign_input?.message, "Gnosis")
        XCTAssertEqual(encryptionService.sign_input?.privateKey, pk)
    }

    func test_whenSignMessageForUnknownAddress_thenThrows() throws {
        do {
            let _: (String, String, Int) = try applicationService.sign(message: "Gnosis", by: "signer")
            XCTFail("Expected to throw")
        } catch {
            // pass
        }
    }

}
