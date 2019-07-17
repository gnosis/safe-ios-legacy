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

    // when onboarding done then shows session list
    // when onboarding not done then shows onboarding
    //                                     has 3 steps
    //                                     1 and 2 step lead to next page
    //                                     3rd step leads to finishing onboarding
    // when onboarding finishes then shows session list
    //                               removes onboarding from stack
    // when shows scan then scanner shown

}
