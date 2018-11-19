//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class PasswordValidatorTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_whenInputIsLessThanRequiredLength_thenReturnsFalse() {
        let str = String(repeating: "a", count: PasswordValidator.minInputLength - 1)
        XCTAssertFalse(PasswordValidator.validateMinLength(str))
    }

    func test_whenInputIsEqualOrGreaterThanRequiredLength_thenReturnsTrue() {
        let equalStr = String(repeating: "a", count: PasswordValidator.minInputLength)
        XCTAssertTrue(PasswordValidator.validateMinLength(equalStr))
        let greaterStr = String(repeating: "a", count: PasswordValidator.minInputLength + 1)
        XCTAssertTrue(PasswordValidator.validateMinLength(greaterStr))
    }

    func test_whenInputHasNoCapitalLetter_thenReturnsFalse() {
        XCTAssertFalse(PasswordValidator.validateAtLeastOneLetterAndOneDigit("a"))
        XCTAssertFalse(PasswordValidator.validateAtLeastOneLetterAndOneDigit("A"))
        XCTAssertFalse(PasswordValidator.validateAtLeastOneLetterAndOneDigit("1"))
    }

    func test_whenInputHasCapitalLetterAndDigit_thenReturnsTrue() {
        XCTAssertTrue(PasswordValidator.validateAtLeastOneLetterAndOneDigit("aB1"))
    }

    func test_whenInputHasTrippleChar_thenReturnsFalse() {
        XCTAssertFalse(PasswordValidator.validateNoTrippleChar("aaa"))
        XCTAssertFalse(PasswordValidator.validateNoTrippleChar(""))
    }

    func test_whenInputEqualToReference_thenReturnsTrue() {
        XCTAssertTrue(PasswordValidator.validate(input: "a", equals: "a"))
    }

    func test_whenInputNotEqualToReference_thenReturnsFalse() {
        XCTAssertFalse(PasswordValidator.validate(input: "a", equals: "b"))
    }
}
