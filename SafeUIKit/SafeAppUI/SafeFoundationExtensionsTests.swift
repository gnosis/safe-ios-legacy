//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class SafeFoundationExtensionsTests: XCTestCase {

    func test_containsCapitalizedLetter() {
        let empty = ""
        let oneLowercase = "a"
        let oneUppercase = "A"
        let manyContainsOneUppercase = "abC"
        let manyContainsNoneUppercase = "abc"
        let manyContainsManyUppercase = "aBC"
        XCTAssertFalse(empty.containsCapitalLetter())
        XCTAssertFalse(oneLowercase.containsCapitalLetter())
        XCTAssertTrue(oneUppercase.containsCapitalLetter())
        XCTAssertTrue(manyContainsOneUppercase.containsCapitalLetter())
        XCTAssertFalse(manyContainsNoneUppercase.containsCapitalLetter())
        XCTAssertTrue(manyContainsManyUppercase.containsCapitalLetter())
    }

    func test_containsDigit() {
        let empty = ""
        let noDigit = "a"
        let oneDigit = "1"
        let manyContainsOneDigit = "ab1"
        let manyContainsNoneDigit = "abc"
        let manyContainsManyDigits = "a12"
        XCTAssertFalse(empty.containsDigit())
        XCTAssertFalse(noDigit.containsDigit())
        XCTAssertTrue(oneDigit.containsDigit())
        XCTAssertTrue(manyContainsOneDigit.containsDigit())
        XCTAssertFalse(manyContainsNoneDigit.containsDigit())
        XCTAssertTrue(manyContainsManyDigits.containsDigit())
    }

}
