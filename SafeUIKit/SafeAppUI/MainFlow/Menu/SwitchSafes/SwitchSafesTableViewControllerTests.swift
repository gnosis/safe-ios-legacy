//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class SwitchSafesTableViewControllerTests: SafeTestCase {

    let controller = SwitchSafesTableViewController()

    override func setUp() {
        super.setUp()
    }

    func test_tracking() {
        controller.viewDidAppear(false)
        XCTAssertTracksAppearance(in: controller, SafesTrackingEvent.switchSafes)
    }

    func test_whenSelectingRow_thenCallsDelegate() {

    }

}
