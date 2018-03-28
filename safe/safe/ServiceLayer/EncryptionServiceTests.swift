//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class EncryptionServiceTests: XCTestCase {

    let service = EncryptionService()

    func test_generateMnemonic() {
        let mnemonic = service.generateMnemonic()
        XCTAssertFalse(mnemonic.words.isEmpty)
    }

    func test_derivePrivateKey_createsPrivateKey() {
        XCTAssertNotNil(service.derivePrivateKey(from: service.generateMnemonic()))
    }

}
