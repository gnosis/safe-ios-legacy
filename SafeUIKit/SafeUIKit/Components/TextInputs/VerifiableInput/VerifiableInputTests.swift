//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class VerifiableInputTests: XCTestCase {

    let input = VerifiableInput()
    // swiftlint:disable:next weak_delegate
    let delegate = MockVerifiableInputDelegate()

    override func setUp() {
        super.setUp()
        input.delegate = delegate
    }

    func test_whenAddingRule_addsLabel() {
        input.addRule("test") { _ in true }
        XCTAssertEqual(input.ruleLabelCount, 1)
        XCTAssertEqual(input.ruleLabel(at: 0).label.text, "test")
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

    func test_whenShouldShowErrorRulesOnly_thenWorks() {
        input.showErrorsOnly = true
        input.addRule("test") { _ in true }
        input.addRule("test2") { _ in false }
        input.type("a")
        XCTAssertEqual(input.ruleLabel(at: 0).isHidden, true)
        XCTAssertEqual(input.ruleLabel(at: 1).isHidden, false)
        XCTAssertEqual(input.textInput.inputState, .error)
    }

    func test_whenLastSymbolErased_thenAllRuleLabelsBecomeInactive() {
        input.addRule("test") { _ in true }
        input.addRule("test2") { _ in false }
        input.type("a")
        input.type("")
        XCTAssertEqual(input.ruleLabel(at: 0).status, .inactive)
        XCTAssertEqual(input.ruleLabel(at: 1).status, .inactive)
        XCTAssertEqual(input.textInput.inputState, .normal)
    }

    func test_whenTextIsCleared_thenAllRuleLabelsAreSetInInactiveState() {
        input.addRule("test") { _ in true }
        input.type("a")
        input.clear()
        XCTAssertEqual(input.ruleLabel(at: 0).status, .inactive)
        XCTAssertEqual(input.textInput.inputState, .normal)
    }

    func test_whenNoRules_thenReturnKeyEnabled() {
        XCTAssertTrue(input.isReturnKeyEnabled)
    }

    func test_whenAllTestsPass_thenReturnKeyEnabled() {
        input.addRule("test1") { _ in true }
        input.addRule("test2") { _ in true }
        input.type("a")
        XCTAssertTrue(input.isReturnKeyEnabled)
        XCTAssertEqual(input.textInput.inputState, .success)
    }

    func test_whenNoRules_thenInputStateIsNormal() {
        input.type("a")
        XCTAssertEqual(input.textInput.inputState, .normal)
    }

    func test_whenReturnKeyPressed_thenCallsDelegate() {
        input.addRule("test1") { _ in true }
        input.type("a")
        input.hitReturn()
        XCTAssertTrue(delegate.didReturnWasCalled)
    }

    func test_whenTypingText_thenTextInputHasText() {
        input.textInput.text = "a"
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
        XCTAssertFalse(input.textInput.isEnabled)
    }

    func test_shake_whenCalled_thenAddsShakeAnimation() {
        let input = TestableVerifiableInput()
        input.delegate = delegate
        input.shake()
        XCTAssertTrue(input.isShaking)
    }

    func test_setText() {
        input.text = "my text"
        XCTAssertEqual(input.text, "my text")
    }

    func test_whenHasWhitespaceAtTheEnds_thenTrimsThem() {
        input.trimsText = true
        input.text = " my text "
        XCTAssertEqual(input.text, "my text")
    }

    func test_whenTrimsTextChanging_thenReTrimsTheText() {
        input.text = " my text "
        XCTAssertEqual(input.text, " my text ")
        input.trimsText = true
        XCTAssertEqual(input.text, "my text")
    }

    func test_setText_hasMax2Chars() {
        input.maxLength = 1
        input.text = "11"
        XCTAssertEqual(input.text, "1")
    }

    func test_whenTryingToTypeMoreThanLength_thenTakesFirstNChars() {
        input.maxLength = 1
        input.textInput.text = "abc"
        input.textInput.sendActions(for: .editingChanged)
        XCTAssertEqual(input.text, "a")
    }

    func test_whenВeginEditing_thenDelegateIsCalled() {
        input.beginEditing()
        XCTAssertTrue(delegate.didBeginEditingWasCalled)
    }

    func test_whenEndEditing_thenDelegateIsCalled() {
        input.endEditing()
        XCTAssertTrue(delegate.didEndEditing)
    }

}

class TestableVerifiableInput: VerifiableInput {

    var isShaking = false

    override func shake() {
        isShaking = true
    }

}


extension VerifiableInput {

    var ruleLabelCount: Int {
        return stackView.arrangedSubviews.count - 1
    }

    var isReturnKeyEnabled: Bool {
        return textFieldShouldReturn(textInput)
    }

    func ruleLabel(at index: Int) -> RuleLabel {
        return stackView.arrangedSubviews[index + 1] as! RuleLabel
    }

    func ruleLabel(by indentifier: String) -> RuleLabel? {
        return stackView.arrangedSubviews.reduce([String: RuleLabel]()) { result, value in
            var r = result
            r[value.accessibilityIdentifier ?? ""] = value as? RuleLabel
            return r
        }[indentifier]
    }

    func type(_ text: String) {
        self.text = text
    }

    func beginEditing() {
        _ = textFieldDidBeginEditing(textInput)
    }

    func endEditing() {
        _ = textFieldDidEndEditing(textInput)
    }

    func clear() {
        _ = textFieldShouldClear(textInput)
    }

    func hitReturn() {
        _ = textFieldShouldReturn(textInput)
    }

}

class MockVerifiableInputDelegate: VerifiableInputDelegate {

    var didReturnWasCalled = false
    var didBeginEditingWasCalled = false
    var didEndEditing = false

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        didReturnWasCalled = true
    }

    func verifiableInputDidBeginEditing(_ verifiableInput: VerifiableInput) {
        didBeginEditingWasCalled = true
    }

    func verifiableInputDidEndEditing(_ verifiableInput: VerifiableInput) {
        didEndEditing = true
    }

}
