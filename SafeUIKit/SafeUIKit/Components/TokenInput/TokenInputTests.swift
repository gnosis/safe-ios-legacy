//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

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

}

private extension TokenInput {

    func canType(_ text: String, range: NSRange = NSRange()) -> Bool {
        if range.length == 0 { textInput.text = "" }
        return textField(textInput, shouldChangeCharactersIn: range, replacementString: text)
    }

}
