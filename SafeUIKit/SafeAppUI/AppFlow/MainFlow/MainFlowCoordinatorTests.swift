//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class MainFlowCoordinatorTests: SafeTestCase {

    var mainFlowCoordinator: MainFlowCoordinator!

    override func setUp() {
        super.setUp()
        mainFlowCoordinator = MainFlowCoordinator(rootViewController: UINavigationController())
    }

    func test_whenSetupCalled_thenShowsMainScreen() {
        mainFlowCoordinator.setUp()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is MainViewController)
    }

}
