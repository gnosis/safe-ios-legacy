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
        XCTAssertNotNil(vc.textInput)
    }

}
