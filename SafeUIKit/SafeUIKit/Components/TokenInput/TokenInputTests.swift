//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt
import Common

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
        XCTAssertTrue(tokenInput.canType("101,001,01"))
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

    func test_whenInsertedValueIsNotANumber_thenProperErrorMessageIsDisplayed() {
        tokenInput.text = "test"
        XCTAssertEqual(tokenInput.ruleLabel(by: "valueIsNotANumber")!.status, .error)
        XCTAssertEqual(tokenInput.ruleLabel(by: "valueIsTooBig")!.status, .success)
        XCTAssertEqual(tokenInput.ruleLabel(by: "excededAmountOfFractionalDigits")!.status, .success)
    }

    func test_whenEnteingTooBigNumber_thenProperErrorMessageIsDisplayed() {
        tokenInput.setUp(value: 0, decimals: TokenBounds.maxDigitsCount - 1)
        tokenInput.endEditing("1")
        XCTAssertEqual(tokenInput.ruleLabel(by: "valueIsTooBig")!.status, .success)
        tokenInput.endEditing("11")
        XCTAssertEqual(tokenInput.ruleLabel(by: "valueIsTooBig")!.status, .error)
    }

    func test_whenFractionalPartHasTooManyDigits_thenProperErrorMessageIsDisplayed() {
        tokenInput.setUp(value: 0, decimals: 3)
        tokenInput.endEditing("1,001")
        XCTAssertEqual(tokenInput.ruleLabel(by: "excededAmountOfFractionalDigits")!.status, .success)
        tokenInput.endEditing("1,00100")
        XCTAssertEqual(tokenInput.ruleLabel(by: "excededAmountOfFractionalDigits")!.status, .success)
        tokenInput.endEditing("1,0001")
        XCTAssertEqual(tokenInput.ruleLabel(by: "excededAmountOfFractionalDigits")!.status, .error)
    }

    func test_whenResignsFirstResponder_thenTextInputResigns() {
        addToWindow(tokenInput)
        _ = tokenInput.becomeFirstResponder()
        XCTAssertTrue(tokenInput.isFirstResponder)
        XCTAssertTrue(tokenInput.textInput.isFirstResponder)
        _ = tokenInput.resignFirstResponder()
        XCTAssertFalse(tokenInput.isFirstResponder)
        XCTAssertFalse(tokenInput.textInput.isFirstResponder)
    }

    func test_whenEndsEditing_thenValueIsUpdatedAndVisibleValueIsFormatted() {
        tokenInput.setUp(value: 0, decimals: 3)

        tokenInput.endEditing("1")
        XCTAssertEqual(tokenInput.value, 1_000)
        XCTAssertEqual(tokenInput.text, "1")

        tokenInput.endEditing("1,01")
        XCTAssertEqual(tokenInput.value, 1_010)
        XCTAssertEqual(tokenInput.text, "1,01")

        tokenInput.endEditing("01,010")
        XCTAssertEqual(tokenInput.value, 1_010)
        XCTAssertEqual(tokenInput.text, "1,01")

        tokenInput.endEditing("1,")
        XCTAssertEqual(tokenInput.value, 1_000)
        XCTAssertEqual(tokenInput.text, "1")
    }

    func test_whenEndsEditingWithErrors_thenValueIsSetToZero() {
        tokenInput.setUp(value: 0, decimals: 3)
        let invalidValue = "001,000100"
        tokenInput.endEditing(invalidValue)
        XCTAssertEqual(tokenInput.value, 0)
        XCTAssertEqual(tokenInput.text, invalidValue)
    }

    func test_whenEnteringAnyPoint_thenTreatsItLikeDecimalPoint() {
        tokenInput.setUp(value: 0, decimals: 3)

        tokenInput.endEditing("1000,000")
        XCTAssertEqual(tokenInput.value, 1_000_000)
        XCTAssertEqual(tokenInput.text, "1000")

        tokenInput.endEditing("1000.000")
        XCTAssertEqual(tokenInput.value, 1_000_000)
        XCTAssertEqual(tokenInput.text, "1000")

        tokenInput.endEditing("1000٫000") // this is actually a different Unicode symbol than dot
        XCTAssertEqual(tokenInput.value, 1_000_000)
        XCTAssertEqual(tokenInput.text, "1000")

        tokenInput.endEditing("1000")
        XCTAssertEqual(tokenInput.value, 1_000_000)
        XCTAssertEqual(tokenInput.text, "1000")
    }

}

private extension TokenInput {

    @discardableResult
    func canType(_ text: String, range: NSRange = NSRange()) -> Bool {
        if range.length == 0 { textInput.text = "" }
        return textField(textInput, shouldChangeCharactersIn: range, replacementString: text)
    }

    func endEditing(_ value: String) {
        canType(value)
        text = value
        textFieldDidEndEditing(textInput)
    }

}
