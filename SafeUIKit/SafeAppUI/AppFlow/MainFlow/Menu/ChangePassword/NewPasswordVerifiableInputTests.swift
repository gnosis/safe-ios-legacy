//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class NewPasswordVerifiableInputTests: XCTestCase {

    let input = NewPasswordVerifiableInput()

    func test_whenTypingInvalidPassword_thenInputIsInvalid() {
        // less than 8 chars
        input.text = "qwer123"
        XCTAssertFalse(input.isValid)
        // no letter
        input.text = "12345678"
        XCTAssertFalse(input.isValid)
        // no digit
        input.text = "qwertyui"
        XCTAssertFalse(input.isValid)
        // tripple char
        input.text = "qwert111"
        XCTAssertFalse(input.isValid)
    }

    func test_whenTypingValidPassword_thenInputIsValid() {
        input.text = "qwert123"
        XCTAssertTrue(input.isValid)
    }

}
