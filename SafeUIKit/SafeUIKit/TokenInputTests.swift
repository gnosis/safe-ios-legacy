//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt
import CommonTestSupport

class TokenInputTests: XCTestCase {

    var tokenInput: TokenInput!
    let germanLocale = Locale(identifier: "de_DE")

    override func setUp() {
        super.setUp()
        tokenInput = TokenInput()
    }

    func test_whenCreated_thenAllElementsAreThere() {
        XCTAssertNotNil(tokenInput.integerTextField)
        XCTAssertNotNil(tokenInput.fractionalTextField)
        XCTAssertEqual(tokenInput.decimals, 18)
        XCTAssertEqual(tokenInput.value, 0)
        XCTAssertNil(tokenInput.fiatConversionRate)
        XCTAssertNil(tokenInput.locale)
        XCTAssertEqual(tokenInput.integerTextField.keyboardType, .decimalPad)
        XCTAssertEqual(tokenInput.fractionalTextField.keyboardType, .numberPad)
    }

    func test_maxTokenValue() {
        XCTAssertEqual(TokenInput.Bounds.maxTokenValue, BigInt(2).power(256) - 1)
    }

    func test_whenSettingUpWithIntialValue_thenDisplayedProperly() {
        assertUI(0, 3, "", "")
        assertUI(1, 3, "", "001")
        assertUI(1, 1, "", "1")
        assertUI(1_001, 3, "1.", "001")
        assertUI(1_001, 3, "1.", "001")
        assertUI(1_001_000, 3, "1001.", "")
        assertUI(1_000_100, 3, "1000.", "1")
        assertUI(1_000_100, 7, "", "10001")
        assertUI(TokenInput.Bounds.maxTokenValue,
                 TokenInput.Bounds.minDecimalCount,
                 "115792089237316195423570985008687907853269984665640564039457584007913129639935.",
                 "")
        assertUI(TokenInput.Bounds.maxTokenValue,
                 TokenInput.Bounds.maxDecimalCount,
                 "",
                 "115792089237316195423570985008687907853269984665640564039457584007913129639935")
    }

    func test_whenTryingToTypeNonDigit_thenNotPossible() {
        XCTAssertTrue(tokenInput.canType("101", field: .integer))
        XCTAssertFalse(tokenInput.canType("A", field: .integer))
        XCTAssertFalse(tokenInput.canType("1A1", field: .integer))
        XCTAssertTrue(tokenInput.canType("101", field: .fractional))
        XCTAssertFalse(tokenInput.canType("A", field: .fractional))
        XCTAssertFalse(tokenInput.canType("1A1", field: .fractional))
    }

    func test_whenNoDecimals_thenFractionalPartIsDisabled() {
        assertUI(1, TokenInput.Bounds.minDecimalCount, "1.", "")
        XCTAssertFalse(tokenInput.fractionalTextField.isEnabled)
    }

    func test_whenMaxDecimalsAllowed_thenIntegerPartIsDisabled() {
        assertUI(0, TokenInput.Bounds.maxDecimalCount, "", "")
        XCTAssertFalse(tokenInput.integerTextField.isEnabled)
    }

    func test_whenTryingToTypeMoreDigitsThanAllowedInFractionalPart_thenNotPossible() {
        tokenInput.setUp(value: 0, decimals: 3)
        XCTAssertTrue(tokenInput.canType("111", field: .fractional))
        XCTAssertFalse(tokenInput.canType("1111", field: .fractional))
    }

    func test_whenTryingToTypeInFractionalPartWithFilledIntegerPart_thenAllows() {
        tokenInput.setUp(value: 1_001, decimals: 3)
        XCTAssertTrue(tokenInput.canType("01", field: .fractional))
    }

    func test_whenTryingToTypeMoreThanAllowedValue_thenNotPossible() {
        tokenInput.setUp(value: 0, decimals: TokenInput.Bounds.maxDecimalCount)
        XCTAssertTrue(tokenInput.canType(
            "115792089237316195423570985008687907853269984665640564039457584007913129639935",
            field: .fractional))
        XCTAssertFalse(tokenInput.canType(
            "115792089237316195423570985008687907853269984665640564039457584007913129639936",
            field: .fractional))
        XCTAssertFalse(tokenInput.canType("1", field: .integer))

        tokenInput.setUp(value: 0, decimals: 0)
        XCTAssertTrue(tokenInput.canType(
            "115792089237316195423570985008687907853269984665640564039457584007913129639935",
            field: .integer))
        XCTAssertFalse(tokenInput.canType(
            "115792089237316195423570985008687907853269984665640564039457584007913129639936",
            field: .integer))

        tokenInput.setUp(value: 0, decimals: 1)
        tokenInput.fractionalTextField.text = "5"
        XCTAssertTrue(tokenInput.canType(
            "11579208923731619542357098500868790785326998466564056403945758400791312963993",
            field: .integer))
        tokenInput.fractionalTextField.text = "6"
        XCTAssertFalse(tokenInput.canType(
            "11579208923731619542357098500868790785326998466564056403945758400791312963993",
            field: .integer))
    }

    func test_whenFinishesEditing_thenValueIsUpdated() {
        tokenInput.setUp(value: 0, decimals: 1)
        tokenInput.endEditing(finalValue: "1", field: .integer)
        XCTAssertEqual(tokenInput.value, 10)
        tokenInput.endEditing(finalValue: "", field: .integer)
        XCTAssertEqual(tokenInput.value, 0)
        tokenInput.endEditing(finalValue: "1", field: .fractional)
        XCTAssertEqual(tokenInput.value, 1)

        tokenInput.setUp(value: 0, decimals: TokenInput.Bounds.maxDecimalCount)
        tokenInput.endEditing(
            finalValue: "115792089237316195423570985008687907853269984665640564039457584007913129639935",
            field: .fractional)
        XCTAssertEqual(tokenInput.value, TokenInput.Bounds.maxTokenValue)

        tokenInput.setUp(value: 0, decimals: 0)
        tokenInput.endEditing(
            finalValue: "115792089237316195423570985008687907853269984665640564039457584007913129639935",
            field: .integer)
        XCTAssertEqual(tokenInput.value, TokenInput.Bounds.maxTokenValue)

        tokenInput.setUp(value: 0, decimals: 18)
        tokenInput.endEditing(finalValue: "1", field: .integer)
        XCTAssertEqual(tokenInput.value, BigInt("1000000000000000000"))
        tokenInput.endEditing(finalValue: "001", field: .fractional)
        XCTAssertEqual(tokenInput.value, BigInt("1001000000000000000"))
    }

    func test_whenFinishesEditing_thenFormattedProperly() {
        tokenInput.setUp(value: 0, decimals: 5)

        tokenInput.endEditing(finalValue: "000001", field: .integer)
        XCTAssertEqual(tokenInput.value, BigInt("100000"))
        XCTAssertEqual(tokenInput.integerTextField.text, "1.")
        XCTAssertEqual(tokenInput.fractionalTextField.text, "")

        tokenInput.endEditing(finalValue: "11000", field: .fractional)
        XCTAssertEqual(tokenInput.value, BigInt("111000"))
        XCTAssertEqual(tokenInput.integerTextField.text, "1.")
        XCTAssertEqual(tokenInput.fractionalTextField.text, "11")
    }

    func test_whenBeginEditing_thenIntegerPartDelimiterIsRemoved() {
        tokenInput.endEditing(finalValue: "1", field: .integer)
        XCTAssertEqual(tokenInput.integerTextField.text, "1.")
        tokenInput.beginEditing(field: .integer)
        XCTAssertEqual(tokenInput.integerTextField.text, "1")
    }

    func test_whenResignsFirstResponder_thenAllTextFieldsResign() {
        addToWindow(tokenInput)

        _ = tokenInput.integerTextField.becomeFirstResponder()
        XCTAssertTrue(tokenInput.isFirstResponder)
        _ = tokenInput.resignFirstResponder()
        XCTAssertFalse(tokenInput.isFirstResponder)

        _ = tokenInput.fractionalTextField.becomeFirstResponder()
        XCTAssertTrue(tokenInput.isFirstResponder)
        _ = tokenInput.resignFirstResponder()
        XCTAssertFalse(tokenInput.isFirstResponder)
    }

    func test_whenFiatConversionRateIsNotKnown_thenFiatValueIsNotDisplayed() {
        XCTAssertEqual(tokenInput.fiatValueLabel.text, "")
    }

    func test_whenfiatConversionRateIsKnown_thenDisplaysItAfterSetup() {
        tokenInput.setUp(value: 1_000, decimals: 3, fiatConversionRate: 0.1, locale: germanLocale)
        XCTAssertEqual(tokenInput.fiatConversionRate, 0.1)
        XCTAssertEqual(tokenInput.locale, germanLocale)
        assertFormatting("0,10")

        tokenInput.setUp(value: 0, decimals: 3, fiatConversionRate: 0.1, locale: germanLocale)
        assertFormatting("")

        tokenInput.setUp(value: 10_000_015, decimals: 3, fiatConversionRate: 0.1, locale: germanLocale)
        assertFormatting("1.000,00")
    }

    func test_whenTyping_thenFiatValueIsUpdated() {
        tokenInput.setUp(value: 0, decimals: 3, fiatConversionRate: 0.1, locale: germanLocale)
        tokenInput.canType("1", field: .integer)
        assertFormatting("0,10")
        tokenInput.endEditing(finalValue: "1", field: .integer)
        assertFormatting("0,10")
        tokenInput.canType("123", field: .fractional)
        assertFormatting("0,11")
        tokenInput.endEditing(finalValue: "123", field: .fractional)
        assertFormatting("0,11")
    }

    func test_whenTypingDecimalSeparatorInIntegerInput_thenSwitchesToFractionalPart() {
        addToWindow(tokenInput)
        tokenInput.setUp(value: 0, decimals: 3, fiatConversionRate: 1, locale: germanLocale)
        _ = tokenInput.integerTextField.becomeFirstResponder()
        tokenInput.canType("1", field: .integer)
        tokenInput.endEditing(finalValue: "1", field: .integer)
        XCTAssertEqual(tokenInput.integerTextField.text, "1.")
        tokenInput.canType((Locale.current as NSLocale).decimalSeparator, field: .integer)
        XCTAssertTrue(tokenInput.fractionalTextField.isFirstResponder)
        XCTAssertEqual(tokenInput.fractionalTextField.text, "")
        assertFormatting("1,00")
    }

    func test_whenAddingLeadingZeroesToIntegerPart_thenNotPossible() {
        XCTAssertFalse(tokenInput.canType("0", field: .integer))
        XCTAssertFalse(tokenInput.canType("000", field: .integer))
        XCTAssertTrue(tokenInput.canType("001", field: .integer))
        tokenInput.endEditing(finalValue: "1", field: .integer)
        XCTAssertTrue(tokenInput.canType("000", field: .integer, range: NSRange(location: 1, length: 1)))
        XCTAssertFalse(tokenInput.canType("000", field: .integer, range: NSRange(location: 0, length: 0)))
    }

}

private extension TokenInputTests {

    func assertUI(_ value: BigInt,
                  _ decimals: Int,
                  _ expectedIntegerPart: String,
                  _ expectedFractionalPart: String) {
        tokenInput.setUp(value: value, decimals: decimals)
        XCTAssertEqual(tokenInput.value, value)
        XCTAssertEqual(tokenInput.integerTextField.text, expectedIntegerPart)
        XCTAssertEqual(tokenInput.fractionalTextField.text, expectedFractionalPart)
    }

    func assertFormatting(_ expected: String) {
        XCTAssertEqual(tokenInput.fiatValueLabel.text, expected == "" ? "" : "≈ \(expected) €")
    }

    func addToWindow(_ tokenInput: TokenInput) {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.addSubview(tokenInput)
    }

}

private extension TokenInput {

    @discardableResult
    func canType(_ text: String, field: TokenInput.Field, range: NSRange = NSRange()) -> Bool {
        let tokenTextField = tokenField(for: field)
        if range.length == 0 { tokenTextField.text = "" }
        return textField(tokenTextField, shouldChangeCharactersIn: range, replacementString: text)
    }

    func endEditing(finalValue: String, field: TokenInput.Field) {
        let tokenTextField = tokenField(for: field)
        tokenTextField.text = finalValue
        _ = textFieldDidEndEditing(tokenTextField)
    }

    func beginEditing(field: TokenInput.Field) {
        let tokenTextField = tokenField(for: field)
        _ = textFieldShouldBeginEditing(tokenTextField)
    }

    func tokenField(for field: TokenInput.Field) -> UITextField {
        var textField: UITextField
        switch field {
        case .integer:
            textField = integerTextField
        case .fractional:
            textField = fractionalTextField
        }
        return textField
    }

}
