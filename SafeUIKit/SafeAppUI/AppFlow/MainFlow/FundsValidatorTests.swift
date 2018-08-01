//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import BigInt

class FundsValidatorTests: XCTestCase {

    func test_validates() {
        let validator = FundsValidator()
        XCTAssertNil(validator.validate(1, 1, 2))
        XCTAssertEqual(validator.validate(1, 0, 0), .notEnoughFunds)
        XCTAssertEqual(validator.validate(0, 1, 0), .notEnoughFunds)
    }

}
