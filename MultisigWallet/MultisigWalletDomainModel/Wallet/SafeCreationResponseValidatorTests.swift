//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class SafeCreationResponseValidatorTests: XCTestCase {

    let validator = SafeCreationResponseValidator()
    let wallet = Wallet(id: WalletID(), owner: Address.deviceAddress)
    let encryptionService = MockEncryptionService1()
    var request: SafeCreationTransactionRequest!

    override func setUp() {
        super.setUp()
        wallet.addOwner(Owner(address: Address.extensionAddress, role: .browserExtension))
        wallet.addOwner(Owner(address: Address.paperWalletAddress, role: .paperWallet))
        wallet.changeConfirmationCount(1)
        request = SafeCreationTransactionRequest.testRequest(wallet, encryptionService)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)

    }
    func test_whenNotMatchingS_thenInvalid() {
        XCTAssertThrowsError(try validator.validate(response(.init(r: "a", s: request.s + "invalid", v: "27")),
                                                    request: request))
    }

    func test_whenPaymentNotANumber_thenInvalid() {
        XCTAssertThrowsError(try validator.validate(response(payment: "asdf"), request: request))
    }

    func test_whenSignatureInvalidValues_thenInvalid() {
        XCTAssertThrowsError(try validator.validate(response(.init(r: "1", s: request.s, v: "348")), request: request))
        XCTAssertThrowsError(try validator.validate(response(.init(r: "1", s: request.s, v: "asdf")), request: request))
        XCTAssertThrowsError(try validator.validate(response(.init(r: "-3", s: request.s, v: "27")), request: request))
        XCTAssertThrowsError(try validator.validate(response(.init(r: "a", s: request.s, v: "27")), request: request))
    }

    func test_whenRecoveredAddressNil_thenInvalid() {
        let response = self.response(payment: "1")
        encryptionService.expect_contractAddress(signature: response.signature.ethSignature,
                                                 transaction: response.tx.ethTransaction,
                                                 address: nil)
        XCTAssertThrowsError(try validator.validate(response, request: request))
    }

    func test_whenRecoveredAddressNotMatchingResponseAddress_thenInvalid() {
        let response = self.response(payment: "1")
        encryptionService.expect_contractAddress(signature: response.signature.ethSignature,
                                                 transaction: response.tx.ethTransaction,
                                                 address: Address.testAccount1.value)
        XCTAssertThrowsError(try validator.validate(response, request: request))
    }

    func test_whenRecoveredAddressMatchingResponseAddress_thenValid() {
        let response = self.response(payment: "1")
        encryptionService.expect_contractAddress(signature: response.signature.ethSignature,
                                                 transaction: response.tx.ethTransaction,
                                                 address: response.safe)
        XCTAssertNoThrow(try validator.validate(response, request: request))
    }


    func response(payment: String) -> SafeCreationTransactionRequest.Response {
        return .init(signature: .init(r: "1", s: request.s, v: "27"),
                     tx: .testTransaction,
                     safe: Address.safeAddress.value,
                     payment: payment)
    }

    func response(_ signature: SafeCreationTransactionRequest.Response.Signature) ->
        SafeCreationTransactionRequest.Response {
            return .init(signature: signature,
                         tx: .testTransaction,
                         safe: Address.safeAddress.value,
                         payment: "1")
    }

}
