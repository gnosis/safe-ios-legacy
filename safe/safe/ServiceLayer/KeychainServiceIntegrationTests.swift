//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class KeychainServiceIntegrationTests: XCTestCase {

    let keychainService = KeychainService(identifier: "KeychainIntegrationTest")
    let correctPassword = "Password"
    let encryptionService = EncryptionService()
    var correctPrivateKey: PrivateKey!

    override func setUp() {
        super.setUp()
        correctPrivateKey = encryptionService.derivePrivateKey(from: encryptionService.generateMnemonic())
        do {
            try keychainService.removePassword()
            try keychainService.removePrivateKey()
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

    func test_password_whenNotSet_thenReturnsNil() {
        do {
            let password = try keychainService.password()
            XCTAssertNil(password)
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

    func test_password_whenSaved_thenReturns() {
        do {
            try keychainService.savePassword(correctPassword)
            let password = try keychainService.password()
            XCTAssertEqual(password, correctPassword)
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

    func test_password_whenRemoved_thenReturnsNil() {
        do {
            try keychainService.savePassword(correctPassword)
            try keychainService.removePassword()
            let password = try keychainService.password()
            XCTAssertNil(password)
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

    func test_privateKey_whenNotSet_thenReturnsNil() {
        do {
            let privateKey = try keychainService.privateKey()
            XCTAssertNil(privateKey)
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

    func test_privateKey_whenSaved_thenReturns() {
        do {
            try keychainService.savePrivateKey(correctPrivateKey)
            let privateKey = try keychainService.privateKey()
            XCTAssertEqual(privateKey, correctPrivateKey)
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

    func test_privateKey_whenRemoved_thenReturnsNil() {
        do {
            try keychainService.savePrivateKey(correctPrivateKey)
            try keychainService.removePrivateKey()
            let privateKey = try keychainService.privateKey()
            XCTAssertNil(privateKey)
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

}
