//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import IdentityAccessApplication

class ChangePasswordFlowCoordinatorTests: SafeTestCase {

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

    func test_whenNewPasswordIsEntered_thenUpdatesPassword() throws {
        try authenticationService.registerUser(password: "Password")
        let newPassword = "NewPassword"
        flowCoordinator.didEnterNewPassword(newPassword)
        XCTAssertEqual(authenticationService.updatedPassword, newPassword)
    }

    func test_whenUpdatePasswordThrows_thenAlertIsShown() {
        authenticationService.shouldThrowDuringUpdatePassword = true
        createWindow(flowCoordinator.navigationController)
        flowCoordinator.didEnterNewPassword("NewPassword")
        delay()
        XCTAssertNotNil(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController)
        XCTAssertTrue(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is UIAlertController)
    }

}
