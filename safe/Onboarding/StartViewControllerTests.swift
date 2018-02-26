//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class StartViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_canCreate() {
        let vc = StartViewController.create()
        vc.loadViewIfNeeded()
        XCTAssertNotNil(vc.headerLabel)
    }

}
