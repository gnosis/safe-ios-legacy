//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SafeFoundationExtensionsTests: XCTestCase {

    func test_containsCapitalizedLetter() {
        let empty = ""
        let oneLowercase = "a"
        let oneUppercase = "A"
        let manyContainsOneUppercase = "abC"
        let manyContainsNoneUppercase = "abc"
        let manyContainsManyUppercase = "aBC"
        XCTAssertFalse(empty.containsCapitalizedLetter())
        XCTAssertFalse(oneLowercase.containsCapitalizedLetter())
        XCTAssertTrue(oneUppercase.containsCapitalizedLetter())
        XCTAssertTrue(manyContainsOneUppercase.containsCapitalizedLetter())
        XCTAssertFalse(manyContainsNoneUppercase.containsCapitalizedLetter())
        XCTAssertTrue(manyContainsManyUppercase.containsCapitalizedLetter())
    }

}
