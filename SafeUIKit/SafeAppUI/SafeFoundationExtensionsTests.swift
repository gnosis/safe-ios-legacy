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
    let manyContainsOneUppercase = "abC"
    let manyContainsNoneUppercase = "abc"
    let manyContainsManyUppercase = "aBC"
    let manyContainsOneDigit = "ab1"
    let manyContainsNoneDigit = "abc"
    let manyContainsManyDigits = "a12"
    let double = "aa"
    let tripple = "aaa"
    let trippleInTheMiddle = "1aaa4"
    let trippleInTheEnd = "1aa4bbb"

    func test_containsCapitalizedLetter() {
        XCTAssertFalse(empty.containsCapitalLetter())
        XCTAssertFalse(oneLowercase.containsCapitalLetter())
        XCTAssertTrue(oneUppercase.containsCapitalLetter())
        XCTAssertTrue(manyContainsOneUppercase.containsCapitalLetter())
        XCTAssertFalse(manyContainsNoneUppercase.containsCapitalLetter())
        XCTAssertTrue(manyContainsManyUppercase.containsCapitalLetter())
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
