//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel

class EthereumAccountTests: XCTestCase {

    let encryptionService = EncryptionService()
    var factory: EthereumAccountFactory!
    var account: EthereumAccountProtocol!

    override func setUp() {
        super.setUp()
        factory = EthereumAccountFactory(service: encryptionService)
        account = factory.generateAccount()
    }

    func test_whenAccountCreated_thenMnemonicCanDerivePrivateKey() {
        let expectedPrivateKey = encryptionService.derivePrivateKey(from: account.mnemonic)
        XCTAssertEqual(account.privateKey, expectedPrivateKey)
    }

    func test_whenAccountCreated_thenEthereumAddressIsDerivedFromPublicKey() {
        let derivedAddress = encryptionService.deriveEthereumAddress(from: account.publicKey)
        XCTAssertEqual(account.address, derivedAddress)
    }

    func test_whenAccountCreated_thenPrivateKeyCanSignAndPublicKeyCanVerify() {
        let message = "MySecret".data(using: .utf8)!
        let signature = encryptionService.sign(message, account.privateKey)
        XCTAssertTrue(encryptionService.isValid(signature: signature, for: message, with: account.publicKey))
    }

    func test_sameMnemonicGeneratesSameAccounts() {
        let mnemonic = account.mnemonic
        let otherAccount = factory.account(from: mnemonic)
        XCTAssertEqual(account as! ExternallyOwnedAccount, otherAccount as! ExternallyOwnedAccount)
    }

}
