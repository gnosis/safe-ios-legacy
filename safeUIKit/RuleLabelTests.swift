//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safeUIKit

class RuleLabelTests: XCTestCase {

    var label: RuleLabel!

    func test_whenStatusChanged_thenTextColorChanged() {
        label = .alwaysTrue
        let initialColor = label.textColor
        validate()
        let changedColor = label.textColor
        XCTAssertNotEqual(changedColor, initialColor)
    }

    func test_whenInitWithText_setsText() {
        XCTAssertEqual(RuleLabel.withText.text, RuleLabel.defaultText)
    }

    func test_whenRulePasses_statusSuccess() {
        label = .alwaysTrue
        validate()
        XCTAssertEqual(label.status, .success)
    }

    func test_whenRuleFails_statusError() {
        label = .alwaysFalse
        validate()
        XCTAssertEqual(label.status, .error)
    }

    func test_whenRuleNotSpecified_alwasyInactive() {
        label = .withoutRule
        validate()
        XCTAssertEqual(label.status, .inactive)
    }

}

private extension RuleLabelTests {

    func validate() {
        let dummyString = ""
        label.validate(dummyString)
    }
}

fileprivate extension RuleLabel {

    static let defaultText = "a"
    static let withoutRule = RuleLabel()
    static let withText = RuleLabel(text: defaultText)
    static let alwaysTrue = RuleLabel(text: defaultText) { _ in true }
    static let alwaysFalse = RuleLabel(text: defaultText) { _ in false }

}
