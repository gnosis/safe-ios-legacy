//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class SetupNewPasswordViewControllerTests: XCTestCase {

    var vc: SetupNewPasswordViewController!
    // swiftlint:disable:next weak_delegate
    let delegate = MockSetupNewPasswordViewControllerDelegate()
    let validPassword = "Qwerty123"

    override func setUp() {
        super.setUp()
        vc = SetupNewPasswordViewController.create(delegate: delegate)
        vc.loadViewIfNeeded()
    }

    func test_Created_thenHasAllElements() {
        XCTAssertNotNil(vc.headerLabel)
        XCTAssertNotNil(vc.newPasswordInput)
        XCTAssertNotNil(vc.confirmNewPasswordInput)
    }

    func test_whenNewPasswordInputDidReturn_thenConfirmPasswordFieldBecomesActive() {
        createWindow(vc)
        XCTAssertTrue(vc.newPasswordInput.isActive)
        XCTAssertFalse(vc.confirmNewPasswordInput.isActive)
        vc.newPasswordInput.text = validPassword
        vc.verifiableInputDidReturn(vc.newPasswordInput)
        XCTAssertTrue(vc.confirmNewPasswordInput.isActive)
    }

    func test_whenConfirmPasswordSucceeded_thenCallsDelegate() {
        vc.newPasswordInput.text = validPassword
        vc.confirmNewPasswordInput.text = validPassword
        XCTAssertNil(delegate.newPassword)
        vc.verifiableInputDidReturn(vc.confirmNewPasswordInput)
        XCTAssertEqual(delegate.newPassword, validPassword)
    }

}

class MockSetupNewPasswordViewControllerDelegate: SetupNewPasswordViewControllerDelegate {

    var newPassword: String?
    func didEnterNewPassword(_ password: String) {
        newPassword = password
    }

}
