//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt

class TokenInputTests: XCTestCase {

    let tokenInput = TokenInput()

    override func setUp() {
        super.setUp()
        tokenInput.locale = Locale(identifier: "de_DE")
    }

    func test_whenTryingToTypeNonDigit_thenNotPossible() {
        XCTAssertTrue(tokenInput.canType("101"))
        XCTAssertFalse(tokenInput.canType("A"))
        XCTAssertFalse(tokenInput.canType("1A1"))
    }

    func test_whenTryingToTypeSeveralSeparators_thenNotPossible() {
        XCTAssertTrue(tokenInput.canType("101,001"))
        XCTAssertFalse(tokenInput.canType("101,001,01"))
        XCTAssertFalse(tokenInput.canType("101,00a"))
    }

    func test_whenSetup_thenTextFieldUpdatedProperly() {
        tokenInput.setUp(value: 0, decimals: 3)
        XCTAssertEqual(tokenInput.text, "")
        tokenInput.setUp(value: 1, decimals: 3)
        XCTAssertEqual(tokenInput.text, "0,001")
        tokenInput.setUp(value: BigInt(10).power(18) + 1, decimals: 18)
        XCTAssertEqual(tokenInput.text, "1,000000000000000001")
    }

    func test_whenEnteingTooBigNumber_thenProperErrorMessageIsDisplayed() {
        tokenInput.setUp(value: 0, decimals: TokenBounds.maxDigitsCount - 1)
        tokenInput.canType("1")
        XCTAssertEqual(tokenInput.ruleLabel(by: "valueIsTooBig")!.status, .success)
        tokenInput.canType("11")
        XCTAssertEqual(tokenInput.ruleLabel(by: "valueIsTooBig")!.status, .error)
    }

    func test_whenFractionalPartHasTooManyDigits_thenProperErrorMessageIsDisplayed() {
        tokenInput.setUp(value: 0, decimals: 3)
        tokenInput.canType("1,001")
        XCTAssertEqual(tokenInput.ruleLabel(by: "excededAmountOfFractionalDigits")!.status, .success)
        tokenInput.canType("1,00100")
        XCTAssertEqual(tokenInput.ruleLabel(by: "excededAmountOfFractionalDigits")!.status, .success)
        tokenInput.canType("1,0001")
        XCTAssertEqual(tokenInput.ruleLabel(by: "excededAmountOfFractionalDigits")!.status, .error)
    }

}

private extension TokenInput {

    @discardableResult
    func canType(_ text: String, range: NSRange = NSRange()) -> Bool {
        if range.length == 0 { textInput.text = "" }
        return textField(textInput, shouldChangeCharactersIn: range, replacementString: text)
    }

}
