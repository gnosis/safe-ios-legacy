//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class ChangePasswordFlowCoordinatorTests: XCTestCase {

    var flowCoordinator: ChangePasswordFlowCoordinator!

    override func setUp() {
        super.setUp()
        flowCoordinator = ChangePasswordFlowCoordinator(rootViewController: UINavigationController())
        flowCoordinator.setUp()
    }

    func test_whenSetupCalled_thenShowsVerifyCurrentPasswordScreen() {
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is VerifyCurrentPasswordViewController)
    }

    func test_whenCurrentPasswordIsVerified_thenSetupNewPasswordVCIsShown() {
        flowCoordinator.didVerifyPassword()
        delay()
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is SetupNewPasswordViewController)
    }

}
