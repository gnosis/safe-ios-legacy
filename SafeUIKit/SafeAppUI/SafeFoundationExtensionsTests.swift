//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class SafeFoundationExtensionsTests: XCTestCase {

    let empty = ""
    let noDigit = "a"
    let oneDigit = "1"
    let oneLowercase = "a"
    let oneUppercase = "A"
    let manyContainsNoneUppercase = "abc"
    let manyContainsOneDigit = "ab1"
    let manyContainsNoneDigit = "abc"
    let manyContainsManyDigits = "a12"
    let double = "aa"
    let tripple = "aaa"
    let trippleInTheMiddle = "1aaa4"
    let trippleInTheEnd = "1aa4bbb"

    func test_containsLetter() {
        XCTAssertFalse(empty.containsLetter())
        XCTAssertFalse(oneDigit.containsLetter())
        XCTAssertTrue(oneLowercase.containsLetter())
        XCTAssertTrue(oneUppercase.containsLetter())
        XCTAssertTrue(manyContainsNoneUppercase.containsLetter())
    }

    func test_containsDigit() {
        XCTAssertFalse(empty.containsDigit())
        XCTAssertFalse(noDigit.containsDigit())
        XCTAssertTrue(oneDigit.containsDigit())
        XCTAssertTrue(manyContainsOneDigit.containsDigit())
        XCTAssertFalse(manyContainsNoneDigit.containsDigit())
        XCTAssertTrue(manyContainsManyDigits.containsDigit())
    }

    func test_noTrippleChars() {
        XCTAssertTrue(empty.noTrippleChar())
        XCTAssertTrue(oneDigit.noTrippleChar())
        XCTAssertTrue(double.noTrippleChar())
        XCTAssertFalse(tripple.noTrippleChar())
        XCTAssertFalse(trippleInTheMiddle.noTrippleChar())
        XCTAssertFalse(trippleInTheEnd.noTrippleChar())
    }

}
