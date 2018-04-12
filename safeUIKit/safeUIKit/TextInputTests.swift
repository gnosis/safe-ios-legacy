//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safeUIKit

class TextInputTests: XCTestCase {

    let input = TextInput()

    func test_whenAddingRule_addsLabel() {
        input.addRule("test") { _ in true }
        XCTAssertEqual(input.ruleLabelCount, 1)
        XCTAssertEqual(input.ruleLabel(at: 0).text, "test")
    }

    func test_whenInitiated_containsNoRules() {
        XCTAssertEqual(input.ruleLabelCount, 0)
    }

    func test_isSecure_whenModified_thenValueIsStored() {
        XCTAssertFalse(input.isSecure)
        input.isSecure = true
        XCTAssertTrue(input.isSecure)
        input.isSecure = false
        XCTAssertFalse(input.isSecure)
    }

    func test_whenAddingEmptyRule_thenRuleLabelIsAlwaysInactive() {
        input.addRule("test")
        XCTAssertEqual(input.ruleLabel(at: 0).status, .inactive)
        input.type("a")
        XCTAssertEqual(input.ruleLabel(at: 0).status, .inactive)
    }

    func test_whenNewCharacterTypedIn_thenValidatesAllRules() {
        input.addRule("test") { _ in true }
        input.addRule("test2") { _ in false }
        input.type("a")
        XCTAssertEqual(input.ruleLabel(at: 0).status, .success)
        XCTAssertEqual(input.ruleLabel(at: 1).status, .error)
    }

    func test_whenLastSymbolErased_thenAllRuleLabelsBecomeInactive() {
        input.addRule("test") { _ in true }
        input.addRule("test2") { _ in false }
        input.type("a")
        input.type("")
        XCTAssertEqual(input.ruleLabel(at: 0).status, .inactive)
        XCTAssertEqual(input.ruleLabel(at: 1).status, .inactive)
    }

    func test_whenTextIsCleared_thenAllRuleLabelsAreSetInInactiveState() {
        input.addRule("test") { _ in true }
        input.type("a")
        input.clear()
        XCTAssertEqual(input.ruleLabel(at: 0).status, .inactive)
    }

    func test_whenNoRules_thenReturnKeyEnabled() {
        XCTAssertTrue(input.isReturnKeyEnabled)
    }

    func test_whenAllTestsPass_thenReturnKeyEnabled() {
        input.addRule("test1") { _ in true }
        input.addRule("test2") { _ in true }
        input.type("a")
        XCTAssertTrue(input.isReturnKeyEnabled)
    }

    func test_whenReturnKeyPressed_thenCallsDelegate() {
        let delegate = MockTextInputDelegate()
        input.delegate = delegate
        input.addRule("test1") { _ in true }
        input.type("a")
        input.hitReturn()
        XCTAssertTrue(delegate.wasCalled)
    }

    func test_whenTypingText_thenTextInputHasText() {
        input.textField.text = "a"
        XCTAssertEqual(input.text, "a")
    }

    func test_whenBecomesFirstResponder_thenIsFocused() {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.addSubview(input)
        _ = input.becomeFirstResponder()
        XCTAssertTrue(input.isActive)
    }

    func test_whenIsEnabledFalse_thenInputFieldDisabled() {
        input.isEnabled = false
        XCTAssertFalse(input.textField.isEnabled)
    }

    func test_shake_whenCalled_thenAddsShakeAnimation() {
        input.shake()
        XCTAssertTrue(input.isShaking)
    }

    func test_setText() {
        input.text = "my text"
        XCTAssertEqual(input.text, "my text")
    }

}

fileprivate extension TextInput {

    var ruleLabelCount: Int {
        return stackView.arrangedSubviews.count - 1
    }

    var isReturnKeyEnabled: Bool {
        return textFieldShouldReturn(textField)
    }

    func ruleLabel(at index: Int) -> RuleLabel {
        return stackView.arrangedSubviews[index + 1] as! RuleLabel
    }

    func type(_ text: String) {
        _ = textField(textField, shouldChangeCharactersIn: NSRange(), replacementString: text)
    }

    func clear() {
        _ = textFieldShouldClear(textField)
    }

    func hitReturn() {
        _ = textFieldShouldReturn(textField)
    }

}

class MockTextInputDelegate: TextInputDelegate {

    var wasCalled = false

    func textInputDidReturn() {
        wasCalled = true
    }

}
