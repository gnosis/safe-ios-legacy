//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class WalletConnectFlowCoordinatorTests: XCTestCase {

    let nav = UINavigationController()
    var fc: WalletConnectFlowCoordinator!

    override func setUp() {
        super.setUp()
        fc = WalletConnectFlowCoordinator(rootViewController: nav)
        fc.setUp()
    }

    func test_onEnter_pushesSessionListViewController() {
        XCTAssertTrue(nav.topViewController is WCSessionListTableViewController)
    }

}
