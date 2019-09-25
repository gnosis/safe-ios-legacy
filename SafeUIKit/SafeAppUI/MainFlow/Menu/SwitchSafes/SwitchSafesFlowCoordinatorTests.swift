//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class SwitchSafesFlowCoordinatorTests: SafeTestCase {

    var switchSafesCoordinator: SwitchSafesFlowCoordinator!

    var topViewController: UIViewController? {
        return switchSafesCoordinator.navigationController.topViewController
    }

    override func setUp() {
        super.setUp()
        switchSafesCoordinator = SwitchSafesFlowCoordinator(rootViewController: UINavigationController())
        switchSafesCoordinator.setUp()
    }

    func test_startViewController_returnsSwitchSafesVC() {
        XCTAssertTrue(topViewController is SwitchSafesTableViewController)
    }

}
