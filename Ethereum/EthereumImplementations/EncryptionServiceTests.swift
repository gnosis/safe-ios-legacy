//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations

class EncryptionServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func canCreate() {
        XCTAssertNotNil(EncryptionService())
    }

}
