//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class ManageTokensFlowCoordinatorTests: XCTestCase {

    var flowCoordinator: ManageTokensFlowCoordinator!

    override func setUp() {
        super.setUp()
        flowCoordinator = ManageTokensFlowCoordinator(rootViewController: UINavigationController())
        flowCoordinator.setUp()
    }

    func test_whenSetupCalled_thenShowsManageTokensScreen() {
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is ManageTokensTableViewController)
    }

}
