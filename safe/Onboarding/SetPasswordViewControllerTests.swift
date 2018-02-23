//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SetPasswordViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_whenLoaded_thenHasAllElements() {
        let vc = SetPasswordViewController.create()
        vc.loadViewIfNeeded()
        XCTAssertNotNil(vc.headerLabel)
        XCTAssertNotNil(vc.passwordTextField)
    }

}
