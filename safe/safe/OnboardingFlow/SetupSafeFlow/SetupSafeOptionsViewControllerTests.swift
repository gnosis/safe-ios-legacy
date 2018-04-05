//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SetupSafeOptionsViewControllerTests: XCTestCase {

    func test_canCreate() {
        let vc = SetupSafeOptionsViewController.create()
        vc.loadViewIfNeeded()
        XCTAssertNotNil(vc.headerLabel)
        XCTAssertNotNil(vc.newSafeButton)
        XCTAssertNotNil(vc.restoreSafeButton)
    }

}
