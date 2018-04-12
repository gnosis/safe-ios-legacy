//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel

class EncryptionServiceTests: XCTestCase {

    let service = EncryptionService()

    func test_generateMnemonic() {
        let mnemonic = service.generateMnemonic()
        XCTAssertFalse(mnemonic.words.isEmpty)
    }

    func test_derivePrivateKey_createsPrivateKey() {
        XCTAssertNotNil(service.derivePrivateKey(from: service.generateMnemonic()))
    }

    func test_derivePublicKey_createsKey() {
        XCTAssertFalse(service.derivePublicKey(from: privateKey()).data.isEmpty)
    }

    func test_sign_signs() {
        let data = "Secret".data(using: .utf8)!
        let otherData = "0123456789".data(using: .utf8)!

        let privateKey = self.privateKey()
        let publicKey = service.derivePublicKey(from: privateKey)

        let otherKey = self.privateKey()
        let otherPublicKey = service.derivePublicKey(from: otherKey)

        let signature = service.sign(data, privateKey)
        let otherSignature = service.sign(data, otherKey)

        XCTAssertTrue(service.isValid(signature: signature, for: data, with: publicKey))
        XCTAssertFalse(service.isValid(signature: signature, for: data, with: otherPublicKey))
        XCTAssertFalse(service.isValid(signature: otherSignature, for: data, with: publicKey))
        XCTAssertFalse(service.isValid(signature: signature, for: otherData, with: publicKey))
    }

    func test_deriveEthereumAddress_createsAddress() {
        let key = privateKey()
        let pkey = service.derivePublicKey(from: key)
        let address = service.deriveEthereumAddress(from: pkey)
        XCTAssertNotNil(address.data)
        XCTAssertEqual(address.data.count, 20)
    }
}

extension EncryptionServiceTests {

    private func privateKey() -> PrivateKey {
        return service.derivePrivateKey(from: service.generateMnemonic())
    }

    private func publicKey() -> PublicKey {
        return service.derivePublicKey(from: privateKey())
    }
}
