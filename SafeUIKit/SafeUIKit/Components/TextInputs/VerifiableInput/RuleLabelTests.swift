//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class RuleLabelTests: XCTestCase {

    var label: RuleLabel!

    func test_whenStatusChanged_thenImageChanged() {
        label = .alwaysTrue()
        let initialImage = label.imageView.image
        validate()
        let changedImage = label.imageView.image
        XCTAssertNotEqual(initialImage, changedImage)
    }

    func test_whenInitWithText_thenSetsText() {
        XCTAssertEqual(RuleLabel.withText().label.text, RuleLabel.defaultText)
    }

    func test_whenRulePasses_thenStatusSuccess() {
        label = .alwaysTrue()
        validate()
        XCTAssertEqual(label.status, .success)
    }

    func test_whenRuleFails_thenStatusError() {
        label = .alwaysFalse()
        validate()
        XCTAssertEqual(label.status, .error)
    }

    func test_whenRuleNotSpecified_thenAlwaysInactive() {
        label = .withoutRule()
        validate()
        XCTAssertEqual(label.status, .inactive)
    }

    func test_whenActiveRuleReset_thenBecomesInactive() {
        label = .alwaysTrue()
        validate()
        label.reset()
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

    static func withoutRule() -> RuleLabel {
        return RuleLabel()
    }

    static func withText() -> RuleLabel {
        return RuleLabel(text: defaultText)
    }

    static func alwaysTrue() -> RuleLabel {
        return RuleLabel(text: defaultText) { _ in true }
    }

    static func alwaysFalse() -> RuleLabel {
        return RuleLabel(text: defaultText) { _ in false }
    }

}
