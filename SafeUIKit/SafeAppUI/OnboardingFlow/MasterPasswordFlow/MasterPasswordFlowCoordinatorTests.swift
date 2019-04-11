//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class MasterPasswordFlowCoordinatorTests: XCTestCase {

    let flowCoordinator = MasterPasswordFlowCoordinator(rootViewController: UINavigationController())

    override func setUp() {
        super.setUp()
        flowCoordinator.setUp()
    }

    func test_startViewController() {
        let controller = flowCoordinator.navigationController.topViewController as! PasswordViewController
        controller.loadViewIfNeeded()
        XCTAssertEqual(controller.headerLabel.text, XCLocalizedString("onboarding.set_password.header"))
    }

    func test_whenDidSetPassword_thenConfirmPasswordIsShown() {
        flowCoordinator.didSetPassword("Any")
        delay()
        let controller = flowCoordinator.navigationController.topViewController as! PasswordViewController
        controller.loadViewIfNeeded()
        XCTAssertEqual(controller.headerLabel.text, XCLocalizedString("onboarding.confirm_password.header"))
    }

    func test_whenDidConfirmPassword_thenFlowCompletionIsCalled() {
        var hasSetMasterPassword = false
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: flowCoordinator) {
            hasSetMasterPassword = true
        }
        flowCoordinator.didConfirmPassword()
        XCTAssertTrue(hasSetMasterPassword)
    }

}
