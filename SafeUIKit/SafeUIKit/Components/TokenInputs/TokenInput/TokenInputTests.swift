//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt

class TokenInputTests: XCTestCase {

    let tokenInput = TokenInput()
    let decimalSeparator: String = (Locale.current as NSLocale).decimalSeparator

    func test_whenTryingToTypeNonDigit_thenNotPossible() {
        XCTAssertTrue(tokenInput.canType("101"))
        XCTAssertFalse(tokenInput.canType("A"))
        XCTAssertFalse(tokenInput.canType("1A1"))
    }

    func test_whenTryingToTypeSeveralSeparators_thenNotPossible() {
        let s = decimalSeparator
        XCTAssertTrue(tokenInput.canType("101\(s)001"))
        XCTAssertFalse(tokenInput.canType("101\(s)001\(s)01"))
        XCTAssertFalse(tokenInput.canType("101\(s)00a"))
    }

    func test_whenSetup_thenTextFieldUpdatedProperly() {
        let s = decimalSeparator
        tokenInput.setUp(value: 0, decimals: 3)
        XCTAssertEqual(tokenInput.text, "")
        tokenInput.setUp(value: 1, decimals: 3)
        XCTAssertEqual(tokenInput.text, "0\(s)001")
        tokenInput.setUp(value: BigInt(10).power(18) + 1, decimals: 18)
        XCTAssertEqual(tokenInput.text, "1\(s)000000000000000001")
    }

}

private extension TokenInput {

    func canType(_ text: String, range: NSRange = NSRange()) -> Bool {
        if range.length == 0 { textInput.text = "" }
        return textField(textInput, shouldChangeCharactersIn: range, replacementString: text)
    }

}
