//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

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
        XCTAssertEqual(vc.minimumLengthRuleLabel.textColor, RuleLabel.color(for: .inactive))
        XCTAssertEqual(vc.capitalLetterRuleLabel.textColor, RuleLabel.color(for: .inactive))
        XCTAssertEqual(vc.digitRuleLabel.textColor, RuleLabel.color(for: .inactive))
    }

    func test_whenFirstLowercaseLetterIsEntered_thenAllRullesAreFailed() {
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: "a")
        XCTAssertEqual(vc.minimumLengthRuleLabel.textColor, RuleLabel.color(for: .error))
        XCTAssertEqual(vc.capitalLetterRuleLabel.textColor, RuleLabel.color(for: .error))
        XCTAssertEqual(vc.digitRuleLabel.textColor, RuleLabel.color(for: .error))
    }

    func test_whenAtLeastOneUppercaseLetterIsEntered_thenAllRullesExceptCapitalLetterRuleAreFailed() {
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: "abCd")
        XCTAssertEqual(vc.minimumLengthRuleLabel.textColor, RuleLabel.color(for: .error))
        XCTAssertEqual(vc.capitalLetterRuleLabel.textColor, RuleLabel.color(for: .success))
        XCTAssertEqual(vc.digitRuleLabel.textColor, RuleLabel.color(for: .error))
    }

    func test_whenAtLeastOneDigitIsEntered_thenAllRullesExceptDigitRuleAreFailed() {
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: "a1b")
        XCTAssertEqual(vc.minimumLengthRuleLabel.textColor, RuleLabel.color(for: .error))
        XCTAssertEqual(vc.capitalLetterRuleLabel.textColor, RuleLabel.color(for: .error))
        XCTAssertEqual(vc.digitRuleLabel.textColor, RuleLabel.color(for: .success))
    }

    func test_whenLessThanMinimumSymbolsAreEntered_thenMinimumLengthRuleIsFailed() {
        // TODO: const
        // Min = 6
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: "abcde")
        XCTAssertEqual(vc.minimumLengthRuleLabel.textColor, RuleLabel.color(for: .error))
    }

    func test_whenAtLeastMinimumLowercaseLettersAreEntered_thenAllRullesExceptMinimumLengthRuleAreFailed() {
        // Min = 6
        _ = vc.textField(vc.passwordTextField, shouldChangeCharactersIn: NSRange(), replacementString: "abcdef")
        XCTAssertEqual(vc.minimumLengthRuleLabel.textColor, RuleLabel.color(for: .success))
        XCTAssertEqual(vc.capitalLetterRuleLabel.textColor, RuleLabel.color(for: .error))
        XCTAssertEqual(vc.digitRuleLabel.textColor, RuleLabel.color(for: .error))
    }

}
