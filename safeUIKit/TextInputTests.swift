//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safeUIKit

class TextInputTests: XCTestCase {

    let input = TextInput.create()

    func test_whenAddingRule_addsLabel() {
        input.addRule("test") { _ in true }
        XCTAssertEqual(input.ruleLabelCount, 1)
        XCTAssertEqual(input.ruleLabel(at: 0).text, "test")
    }

    func test_whenInitiated_containsNoRules() {
        XCTAssertEqual(input.ruleLabelCount, 0)
    }

    func test_whenNewCharacterTypedIn_thenValidatesAllRules() {
        input.addRule("test") { _ in true }
        input.addRule("test2") { _ in false }
        input.type("a")
        XCTAssertEqual(input.ruleLabel(at: 0).status, .success)
        XCTAssertEqual(input.ruleLabel(at: 1).status, .error)
    }

    func test_whenLastSymbolErased_thenAllRulesBecomeInactive() {
        input.addRule("test") { _ in true }
        input.addRule("test2") { _ in false }
        input.type("a")
        input.type("")
        XCTAssertEqual(input.ruleLabel(at: 0).status, .inactive)
        XCTAssertEqual(input.ruleLabel(at: 1).status, .inactive)
    }

    func test_whenTextIsCleared_thenAllRulesAreSetInInactiveState() {
        input.addRule("test") { _ in true }
        input.type("a")
        input.clear()
        XCTAssertEqual(input.ruleLabel(at: 0).status, .inactive)
    }

}

fileprivate extension TextInput {

    var ruleLabelCount: Int {
        return stackView.arrangedSubviews.count - 1
    }

    func ruleLabel(at index: Int) -> RuleLabel {
        return stackView.arrangedSubviews[index + 1] as! RuleLabel
    }

    func type(_ text: String) {
        _ = self.textField(textField, shouldChangeCharactersIn: NSRange(), replacementString: text)
    }

    func clear() {
        _ = self.textFieldShouldClear(textField)
    }

}
