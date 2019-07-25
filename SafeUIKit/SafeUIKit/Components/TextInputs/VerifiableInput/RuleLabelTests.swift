//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class RuleLabelTests: XCTestCase {

    func test_whenStatusChanged_thenImageChanged() {
        let label = RuleLabel.alwaysTrue(displayIcon: true)
        let initialImage = label.imageView.image
        label.validate()
        let changedImage = label.imageView.image
        XCTAssertNotEqual(initialImage, changedImage)
    }

    func test_whenInitWithText_thenSetsText() {
        XCTAssertEqual(RuleLabel.withoutRule().label.text, RuleLabel.defaultText)
    }

    func test_whenInitWithoutIcon_thenImageViewIsRemoved() {
        let label = RuleLabel(text: "test", displayIcon: false)
        XCTAssertNil(label.imageView)

        let label2 = RuleLabel(text: "test", displayIcon: true)
        XCTAssertNotNil(label2.imageView)
    }

    func test_whenRulePasses_thenStatusSuccess() {
        let label = RuleLabel.alwaysTrue()
        label.validate()
        XCTAssertEqual(label.status, .success)
        XCTAssertEqual(label.label.textColor, ColorName.hold.color)

        let label2 = RuleLabel.alwaysTrue(displayIcon: true)
        label2.validate()
        XCTAssertEqual(label2.status, .success)
        XCTAssertEqual(label2.label.textColor, ColorName.darkGrey.color)
    }

    func test_whenRuleFails_thenStatusError() {
        let label = RuleLabel.alwaysFalse()
        label.validate()
        XCTAssertEqual(label.status, .error)
        XCTAssertEqual(label.label.textColor, ColorName.tomato.color)

        let label2 = RuleLabel.alwaysFalse(displayIcon: true)
        label2.validate()
        XCTAssertEqual(label2.status, .error)
        XCTAssertEqual(label2.label.textColor, ColorName.darkGrey.color)
    }

    func test_whenRuleNotSpecified_thenAlwaysInactive() {
        let label = RuleLabel.withoutRule()
        label.validate()
        XCTAssertEqual(label.status, .inactive)
        XCTAssertEqual(label.label.textColor, ColorName.darkGrey.color)

        let label2 = RuleLabel.withoutRule(displayIcon: true)
        label2.validate()
        XCTAssertEqual(label2.status, .inactive)
        XCTAssertEqual(label2.label.textColor, ColorName.darkGrey.color)
    }

    func test_whenActiveRuleReset_thenBecomesInactive() {
        let label = RuleLabel.alwaysTrue()
        label.validate()
        label.reset()
        XCTAssertEqual(label.status, .inactive)
    }

}

private extension RuleLabel {

    static let defaultText = "a"

    func validate() {
        validate(RuleLabel.defaultText)
    }

    static func withoutRule(displayIcon: Bool = false) -> RuleLabel {
        return RuleLabel(text: defaultText, displayIcon: displayIcon)
    }

    static func alwaysTrue(displayIcon: Bool = false) -> RuleLabel {
        return RuleLabel(text: defaultText, displayIcon: displayIcon) { _ in true }
    }

    static func alwaysFalse(displayIcon: Bool = false) -> RuleLabel {
        return RuleLabel(text: defaultText, displayIcon: displayIcon) { _ in false }
    }

}
