//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import BigInt
import SafeUIKit

class TokenAmountValidatorTests: XCTestCase {

    func test_validate() {
        let formatter = TokenNumberFormatter()
        let validator = TokenAmountValidator(formatter: formatter, range: BigInt(1)..<BigInt(3))
        XCTAssertEqual(validator.validate(""), .empty)
        XCTAssertEqual(validator.validate("-1"), .valueIsNegative)
        XCTAssertEqual(validator.validate("0"), .valueIsTooSmall)
        XCTAssertEqual(validator.validate("3"), .valueIsTooBig)
        XCTAssertEqual(validator.validate("asdf"), .notANumber)
    }

}
