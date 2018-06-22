//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt

class TokenInputTests: XCTestCase {

    var tokenInput: TokenInput!

    override func setUp() {
        super.setUp()
        tokenInput = TokenInput()
    }

    func test_whenCreated_thenAllElementsAreThere() {
        XCTAssertNotNil(tokenInput.integerPartTextField)
        XCTAssertNotNil(tokenInput.fractionalPartTextField)
        XCTAssertEqual(tokenInput.decimals, 18)
        XCTAssertEqual(tokenInput.value, 0)
    }

    func test_maxTokenValue() {
        XCTAssertEqual(tokenInput._2_pow_256_minus_1, BigInt(2).power(256) - 1)
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
        assertUI(tokenInput._2_pow_256_minus_1,
                 0,
                 "115792089237316195423570985008687907853269984665640564039457584007913129639935.",
                 "")
        assertUI(tokenInput._2_pow_256_minus_1,
                 78,
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
        assertUI(1, 0, "1.", "")
        XCTAssertFalse(tokenInput.fractionalPartTextField.isEnabled)
    }

    func test_whenMaxDecimalsAllowed_thenIntegerPartIsDisabled() {
        assertUI(0, 78, "", "")
        XCTAssertFalse(tokenInput.integerPartTextField.isEnabled)
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
        tokenInput.setUp(value: 0, decimals: 78)
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
        tokenInput.fractionalPartTextField.text = "5"
        XCTAssertTrue(tokenInput.canType(
            "11579208923731619542357098500868790785326998466564056403945758400791312963993",
            field: .integer))
        tokenInput.fractionalPartTextField.text = "6"
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

        tokenInput.setUp(value: 0, decimals: 78)
        tokenInput.endEditing(
            finalValue: "115792089237316195423570985008687907853269984665640564039457584007913129639935",
            field: .fractional)
        XCTAssertEqual(tokenInput.value, tokenInput._2_pow_256_minus_1)

        tokenInput.setUp(value: 0, decimals: 0)
        tokenInput.endEditing(
            finalValue: "115792089237316195423570985008687907853269984665640564039457584007913129639935",
            field: .integer)
        XCTAssertEqual(tokenInput.value, tokenInput._2_pow_256_minus_1)

        tokenInput.setUp(value: 0, decimals: 18)
        tokenInput.endEditing(finalValue: "1", field: .integer)
        XCTAssertEqual(tokenInput.value, BigInt("1000000000000000000"))
        tokenInput.endEditing(finalValue: "001", field: .fractional)
        XCTAssertEqual(tokenInput.value, BigInt("1001000000000000000"))
    }

    func test_whenBeginEditing_thenIntegerPartDelimiterIsRemoved() {
        tokenInput.endEditing(finalValue: "1", field: .integer)
        XCTAssertEqual(tokenInput.integerPartTextField.text, "1.")
        tokenInput.beginEditing(field: .integer)
        XCTAssertEqual(tokenInput.integerPartTextField.text, "1")
    }

    func test_whenResignsFirstResponder_thenAllTextFieldsResign() {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.addSubview(tokenInput)

        _ = tokenInput.integerPartTextField.becomeFirstResponder()
        XCTAssertTrue(tokenInput.isFirstResponder)
        _ = tokenInput.resignFirstResponder()
        XCTAssertFalse(tokenInput.isFirstResponder)

        _ = tokenInput.fractionalPartTextField.becomeFirstResponder()
        XCTAssertTrue(tokenInput.isFirstResponder)
        _ = tokenInput.resignFirstResponder()
        XCTAssertFalse(tokenInput.isFirstResponder)
    }

}

private extension TokenInputTests {

    func assertUI(_ value: BigInt,
                  _ decimals: Int,
                  _ expectedIntegerPart: String,
                  _ expectedFractionalPart: String) {
        tokenInput.setUp(value: value, decimals: decimals)
        XCTAssertEqual(tokenInput.value, value)
        XCTAssertEqual(tokenInput.integerPartTextField.text, expectedIntegerPart)
        XCTAssertEqual(tokenInput.fractionalPartTextField.text, expectedFractionalPart)
    }

}

private extension TokenInput {

    func canType(_ text: String, field: TokenInput.Field) -> Bool {
        let tokenTextField = tokenField(for: field)
        tokenTextField.text = ""
        return textField(tokenTextField, shouldChangeCharactersIn: NSRange(), replacementString: text)
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
            textField = integerPartTextField
        case .fractional:
            textField = fractionalPartTextField
        }
        return textField
    }

}
