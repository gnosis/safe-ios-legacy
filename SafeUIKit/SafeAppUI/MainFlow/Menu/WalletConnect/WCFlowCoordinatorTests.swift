//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class WCFlowCoordinatorTests: XCTestCase {

    let nav = UINavigationController()
    var fc: WCFlowCoordinator!

    override func setUp() {
        super.setUp()
        fc = WCFlowCoordinator(rootViewController: nav)
        fc.setUp()
    }

    func test_onEnter_pushesSessionListViewController() {
        XCTAssertTrue(nav.topViewController is WCSessionListTableViewController)
    }

}
