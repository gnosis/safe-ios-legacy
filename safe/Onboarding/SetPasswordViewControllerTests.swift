//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe
import safeUIKit

class SetPasswordViewControllerTests: XCTestCase {

    let vc = SetPasswordViewController.create()

    override func setUp() {
        super.setUp()
        vc.loadViewIfNeeded()
    }

    func test_whenLoaded_thenHasAllElements() {
        XCTAssertNotNil(vc.headerLabel)
        XCTAssertNotNil(vc.passwordTextField)
    }

    func test_whenPasswordRuleErrors_displaysAsRed() {
        vc.setMinimumLengthRuleStatus(.error)
        XCTAssertEqual(vc.minimumLengthRuleLabel.textColor, RuleLabel.color(for: .error))
    }

    func test_whenCapitalLetterRuleErrors_displaysAsRed() {
        vc.setCapitalLetterRuleStatus(.error)
        XCTAssertEqual(vc.capitalLetterRuleLabel.textColor, RuleLabel.color(for: .error))
    }

    func test_whenDigitRuleErrors_displaysAsRed() {
        vc.setDigitRuleStatus(.error)
        XCTAssertEqual(vc.digitRuleLabel.textColor, RuleLabel.color(for: .error))
    }

    func test_whenAppearing_thenFocusesOnPasswordField() {
        // we must bring VC.view on the screen
        // because view controller is not in the responder chain
        // and will ignore becomeFirstResponder calls.
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Can't find window for testing")
            return
        }
        window.addSubview(vc.view)
        XCTAssertTrue(vc.passwordTextField.isFirstResponder)
    }

    func test_whenLastSymbolErased_thenAllRulesBecomeInactive() {
        vc.passwordTextField.text = "a"
        _ = vc.textField(vc.passwordTextField,
                         shouldChangeCharactersIn: NSRange(location: 0, length: 1),
                         replacementString: "")
        assertFieldsState(minimumLength: .inactive, capitalLetter: .inactive, digit: .inactive)
    }

    // TODO: move out to Password Validator
    func test_whenFirstLowercaseLetterIsEntered_thenAllRullesAreFailed() {
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: "a")
        assertFieldsState(minimumLength: .error, capitalLetter: .error, digit: .error)
    }

    func test_whenAtLeastOneUppercaseLetterIsEntered_thenAllRullesExceptCapitalLetterRuleAreFailed() {
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: "abCd")
        assertFieldsState(minimumLength: .error, capitalLetter: .success, digit: .error)
    }

    func test_whenAtLeastOneDigitIsEntered_thenAllRullesExceptDigitRuleAreFailed() {
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: "a1b")
        assertFieldsState(minimumLength: .error, capitalLetter: .error, digit: .success)
    }

    func test_whenLessThanMinimumSymbolsAreEntered_thenMinimumLengthRuleIsFailed() {
        let str = String(repeating: "a", count: vc.minCharsInPassword - 1)
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: str)
        XCTAssertEqual(vc.minimumLengthRuleLabel.textColor, RuleLabel.color(for: .error))
    }

    func test_whenAtLeastMinimumLowercaseLettersAreEntered_thenAllRullesExceptMinimumLengthRuleAreFailed() {
        let str = String(repeating: "a", count: vc.minCharsInPassword)
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: str)
        assertFieldsState(minimumLength: .success, capitalLetter: .error, digit: .error)
    }

    func test_whenPasswordIsCleared_thenAllRulesAreSetInInactiveState() {
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: "1Password")
        assertFieldsState(minimumLength: .success, capitalLetter: .success, digit: .success)
        _ = vc.textFieldShouldClear(vc.passwordTextField)
        assertFieldsState(minimumLength: .inactive, capitalLetter: .inactive, digit: .inactive)

    }

    private func assertFieldsState(minimumLength: RuleStatus, capitalLetter: RuleStatus, digit: RuleStatus) {
        XCTAssertEqual(vc.minimumLengthRuleLabel.textColor, RuleLabel.color(for: minimumLength))
        XCTAssertEqual(vc.capitalLetterRuleLabel.textColor, RuleLabel.color(for: capitalLetter))
        XCTAssertEqual(vc.digitRuleLabel.textColor, RuleLabel.color(for: digit))
    }

}
