//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class EthereumAccountFactoryTests: XCTestCase {

    func test_whenAccountCreated_thenPrivateKeyCanDecryptTextEncryptedWithPublicKey() {
        let secretText = "MySecret"

        let encryptionService = EncryptionService()
        let account = EthereumAccountFactory().generateAccount()
        let encryptedData = encryptionService.encrypt(secretText, account.publicKey)
        let decryptedData = encryptionService.decrypt(encryptedData, account.privateKey)
        if let string = String(data: decryptedData, encoding: .utf8) {
            XCTAssertEqual(string, secretText)
        } else {
            XCTFail("Decryption failed")
        }
    }

    func test_whenAccountCreated_thenMnemonicCanDerivePrivateKey() {
        let account = EthereumAccountFactory().generateAccount()
        let encryptionService = EncryptionService()
        let privateKey = encryptionService.derivePrivateKey(from: account.mnemonic)
        XCTAssertEqual(account.privateKey, privateKey)
    }

    func test_whenAccountCreated_thenEthereumAddressIsDerivedFromPublicKey() {
        let account = EthereumAccountFactory().generateAccount()
        let encryptionService = EncryptionService()
        let derivedAddress = encryptionService.deriveEthereumAddress(from: account.publicKey)
        XCTAssertEqual(account.address, derivedAddress)
    }

}
