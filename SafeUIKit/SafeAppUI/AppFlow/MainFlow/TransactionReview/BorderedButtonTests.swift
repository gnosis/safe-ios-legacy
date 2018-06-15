//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class BorderedButtonTests: XCTestCase {

    func test_whenDisabledOrHighlighted_thenChangesBackground() {
        let button = BorderedButton()
        let background = button.backgroundColor
        button.isEnabled = false
        XCTAssertNotEqual(button.backgroundColor, background)
        button.isEnabled = true
        button.isHighlighted = true
        XCTAssertNotEqual(button.backgroundColor, background)
    }

    func test_whenPreparedForIB_thenChangesTitleColor() {
        let button = BorderedButton()
        let normalColor = button.titleColor(for: .normal)
        let disabledColor = button.titleColor(for: .disabled)
        button.isEnabled = false
        button.prepareForInterfaceBuilder()
        XCTAssertEqual(button.titleColor(for: .normal), disabledColor)
        button.isEnabled = true
        button.prepareForInterfaceBuilder()
        XCTAssertEqual(button.titleColor(for: .normal), normalColor)
    }

}
