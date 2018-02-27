//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safeUIKit

class RuleLabelTests: XCTestCase {

    let label = RuleLabel()

    override func setUp() {
        super.setUp()
        label.awakeFromNib()
    }

    func test_whenInitialized_thenInactive() {
        XCTAssertEqual(label.status, .inactive)
    }

    func test_whenStatusChanged_thenTextColorChanged() {
        label.status = .inactive
        let initialColor = label.textColor
        label.status = .error
        let changedColor = label.textColor
        XCTAssertNotEqual(changedColor, initialColor)
    }

}
