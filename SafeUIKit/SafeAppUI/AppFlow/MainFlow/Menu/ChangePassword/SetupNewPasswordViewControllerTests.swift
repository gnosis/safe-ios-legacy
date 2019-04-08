//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import SafeUIKit

class SetupNewPasswordViewControllerTests: XCTestCase {

    var vc: SetupNewPasswordViewController!
    var testableVC: TestableSetupNewPasswordViewController!
    // swiftlint:disable:next weak_delegate
    let delegate = MockSetupNewPasswordViewControllerDelegate()
    let validPassword = "Qwerty123"
    let invalidPassword = "Qwerty1"

    override func setUp() {
        super.setUp()
        vc = SetupNewPasswordViewController.create(delegate: delegate)
        vc.loadViewIfNeeded()
        testableVC = TestableSetupNewPasswordViewController()
        testableVC.loadViewIfNeeded()
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

    func test_whenConfirmPasswordReturns_thenCallsDelegate() {
        setNewPassword(validPassword, vc: vc)
        setConfirmedPassword(validPassword, vc: vc)
        XCTAssertNil(delegate.newPassword)
        vc.verifiableInputDidReturn(vc.confirmNewPasswordInput)
        XCTAssertEqual(delegate.newPassword, validPassword)
    }

    func test_whenSaving_thenCallsDelegate() {
        setNewPassword(validPassword, vc: vc)
        setConfirmedPassword(validPassword, vc: vc)
        XCTAssertNil(delegate.newPassword)
        vc.save()
        XCTAssertEqual(delegate.newPassword, validPassword)
    }

    func test_whenNewPasswordReturnsWithInvalidValue_thenShakes() {
        setNewPassword(invalidPassword, vc: testableVC)
        testableVC.verifiableInputDidReturn(testableVC.newPasswordInput)
        XCTAssertEqual(testableVC.shakedInputs.count, 1)
        XCTAssertTrue(testableVC.shakedInputs.first === testableVC.newPasswordInput)
    }

    func test_whenConfirmPasswordReturnsWithInvalidValue_thenShakes() {
        setNewPassword(validPassword, vc: testableVC)
        setConfirmedPassword(invalidPassword, vc: testableVC)
        testableVC.verifiableInputDidReturn(testableVC.confirmNewPasswordInput)
        XCTAssertEqual(testableVC.shakedInputs.count, 1)
        XCTAssertTrue(testableVC.shakedInputs.first === testableVC.confirmNewPasswordInput)
    }

    func test_whenConfirmPasswordReturnsWithValidValueButCanNotSave_thenNewPasswordFieldShakes() {
        setNewPassword(invalidPassword, vc: testableVC)
        setConfirmedPassword(invalidPassword, vc: testableVC)
        testableVC.verifiableInputDidReturn(testableVC.confirmNewPasswordInput)
        XCTAssertEqual(testableVC.shakedInputs.count, 1)
        XCTAssertTrue(testableVC.shakedInputs.first === testableVC.newPasswordInput)
    }

}

extension SetupNewPasswordViewControllerTests {

    private func setNewPassword(_ password: String, vc: SetupNewPasswordViewController) {
        vc.newPasswordInput.text = password
        vc.verifiableInputWillEnter(vc.newPasswordInput, newValue: password)
    }

    private func setConfirmedPassword(_ password: String, vc: SetupNewPasswordViewController) {
        vc.confirmNewPasswordInput.text = password
        vc.verifiableInputWillEnter(vc.confirmNewPasswordInput, newValue: password)
    }

}

class MockSetupNewPasswordViewControllerDelegate: SetupNewPasswordViewControllerDelegate {

    var newPassword: String?
    func didEnterNewPassword(_ password: String) {
        newPassword = password
    }

}

class TestableSetupNewPasswordViewController: SetupNewPasswordViewController {

    let _scrollView = UIScrollView()
    let _headerLabel = UILabel()
    let _passwordInput = NewPasswordVerifiableInput()
    let _confirmInput = VerifiableInput()

    init() {
        super.init(nibName: nil, bundle: nil)
        scrollView = _scrollView
        headerLabel = _headerLabel
        newPasswordInput = _passwordInput
        confirmNewPasswordInput = _confirmInput
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var shakedInputs = [VerifiableInput]()
    override func shakeInput(_ verifiableInput: VerifiableInput) {
        shakedInputs.append(verifiableInput)
    }

}
