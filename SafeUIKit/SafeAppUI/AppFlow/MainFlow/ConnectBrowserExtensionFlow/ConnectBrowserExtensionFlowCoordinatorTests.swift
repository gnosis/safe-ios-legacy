//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class ConnectBrowserExtensionFlowCoordinatorTests: XCTestCase {

    var connectExtensionFlowCoordinator: ConnectBrowserExtensionFlowCoordinator!

    override func setUp() {
        super.setUp()
        connectExtensionFlowCoordinator =
            ConnectBrowserExtensionFlowCoordinator(rootViewController: UINavigationController())
        connectExtensionFlowCoordinator.setUp()
    }

    func test_whenSetupCalled_thenShowsPairViewController() {
        let topController = connectExtensionFlowCoordinator.navigationController.topViewController
        XCTAssertTrue(topController is PairWithBrowserExtensionViewController)
    }

}
