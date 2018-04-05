//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class EthereumAccountTests: XCTestCase {

    func test_whenAccountCreated_thenMnemonicCanDerivePrivateKey() {
        let service = EncryptionService()
        let account = EthereumAccountFactory(service: service).generateAccount()
        let expectedPrivateKey = service.derivePrivateKey(from: account.mnemonic)
        XCTAssertEqual(account.privateKey, expectedPrivateKey)
    }

    func test_whenAccountCreated_thenEthereumAddressIsDerivedFromPublicKey() {
        let encryptionService = EncryptionService()
        let account = EthereumAccountFactory(service: encryptionService).generateAccount()
        let derivedAddress = encryptionService.deriveEthereumAddress(from: account.publicKey)
        XCTAssertEqual(account.address, derivedAddress)
    }

    func test_whenAccountCreated_thenPrivateKeyCanSignAndPublicKeyCanVerify() {
        let message = "MySecret".data(using: .utf8)!

        let encryptionService = EncryptionService()
        let account = EthereumAccountFactory(service: encryptionService).generateAccount()
        let signature = encryptionService.sign(message, account.privateKey)
        XCTAssertTrue(encryptionService.isValid(signature: signature, for: message, with: account.publicKey))
    }

}
