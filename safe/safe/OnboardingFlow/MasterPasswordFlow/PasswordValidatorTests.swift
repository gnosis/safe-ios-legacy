//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

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
        XCTAssertFalse(PasswordValidator.validateAtLeastOneCapitalLetter("a"))
    }

    func test_whenInputHasCapitalLetter_thenReturnsTrue() {
        XCTAssertTrue(PasswordValidator.validateAtLeastOneCapitalLetter("aB"))
    }

    func test_whenInputHasNoDigits_thenReturnsFalse() {
        XCTAssertFalse(PasswordValidator.validateAtLeastOneDigit("a"))
    }

    func test_whenInputHasDigit_thenReturnsTrue() {
        XCTAssertTrue(PasswordValidator.validateAtLeastOneDigit("a1"))
    }

    func test_whenInputEqualToReference_thenReturnsTrue() {
        XCTAssertTrue(PasswordValidator.validate(input: "a", equals: "a"))
    }

    func test_whenInputNotEqualToReference_thenReturnsFalse() {
        XCTAssertFalse(PasswordValidator.validate(input: "a", equals: "b"))
    }
}
