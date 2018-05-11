//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class PendingSafeViewControllerTests: XCTestCase {

    let controller = PendingSafeViewController.create()

    func test_canCreate() {
        controller.loadViewIfNeeded()
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.progressView)
        XCTAssertNotNil(controller.progressStatusLabel)
        XCTAssertNotNil(controller.cancelButton)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.infoLabel)
        XCTAssertNotNil(controller.safeAddressLabel)
    }

}
