//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt

class TokenInputTests: XCTestCase {

    var tokenInput: TokenInput!

    override func setUp() {
        super.setUp()
        tokenInput = TokenInput()
    }

    func test_whenCreated_thenAllElementsAreThere() {
        XCTAssertNotNil(tokenInput.integerPartTextField)
        XCTAssertNotNil(tokenInput.fractionalPartTextField)
        XCTAssertEqual(tokenInput.decimals, 18)
        XCTAssertEqual(tokenInput.value, 0)
    }

    func test_maxTokenValue() {
        XCTAssertEqual(tokenInput._2_pow_256_minus_1, BigInt(2).power(256) - 1)
    }

    func test_whenSettingUpWithIntialValue_thenDisplayedProperly() {
        assertUI(0, 3, "", "")
        assertUI(1, 3, "", "001")
        assertUI(1, 1, "", "1")
        assertUI(1_001, 3, "1.", "001")
        assertUI(1_001, 3, "1.", "001")
        assertUI(1_001_000, 3, "1001.", "")
        assertUI(1_000_100, 3, "1000.", "1")
        assertUI(1_000_100, 7, "", "10001")
        assertUI(tokenInput._2_pow_256_minus_1,
                 0,
                 "115792089237316195423570985008687907853269984665640564039457584007913129639935.",
                 "")
        assertUI(tokenInput._2_pow_256_minus_1,
                 78,
                 "",
                 "115792089237316195423570985008687907853269984665640564039457584007913129639935")
    }

    func test_whenNoDecimals_thenFractionalPartIsDisabled() {
        assertUI(1, 0, "1.", "")
        XCTAssertFalse(tokenInput.fractionalPartTextField.isEnabled)
    }

}

extension TokenInputTests {

    private func assertUI(_ value: BigInt,
                          _ decimals: Int,
                          _ expectedIntegerPart: String,
                          _ expectedFractionalPart: String) {
        tokenInput.setUp(value: value, decimals: decimals)
        XCTAssertEqual(tokenInput.value, value)
        XCTAssertEqual(tokenInput.integerPartTextField.text, expectedIntegerPart)
        XCTAssertEqual(tokenInput.fractionalPartTextField.text, expectedFractionalPart)
    }
}
