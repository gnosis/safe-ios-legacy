//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class ConfirmPaswordViewControllerTests: XCTestCase {

    let account = MockAccount()
    // swiftlint:disable weak_delegate
    let delegate = MockConfirmPasswordViewControllerDelegate()
    var vc: ConfirmPaswordViewController!

    override func setUp() {
        super.setUp()
        vc = ConfirmPaswordViewController.create(account: account, referencePassword: "a", delegate: delegate)
        vc.loadViewIfNeeded()
    }

    func test_whenCreated_hasAllElements() {
        XCTAssertNotNil(vc.textInput)
    }

    func test_whenDidConfirmPassword_thenPasswordIsSaved() {
        account.didCleanData = false
        account.didSavePassword = false
        vc.textInputDidReturn()
        XCTAssertTrue(account.didCleanData)
        XCTAssertTrue(account.didSavePassword)
    }

    func test_whenTextInputDidReturn_thenBiometricActivationRequested() {
        account.didRequestBiometricActivation = false
        vc.textInputDidReturn()
        XCTAssertTrue(account.didRequestBiometricActivation)
    }

    func test_whenBiometricActivationCompleted_thenCallsDelegate() {
        delegate.didConfirm = false
        vc.textInputDidReturn()
        XCTAssertFalse(delegate.didConfirm)
        account.finishBiometricActivation()
        wait()
        XCTAssertTrue(delegate.didConfirm)
    }

    func test_whenSetMasterPasswordThrows_thenDelegateNotCalled() {
        delegate.didConfirm = false
        account.setMasterPasswordThrows = true
        vc.textInputDidReturn()
        XCTAssertFalse(delegate.didConfirm)
    }

    func test_whenSetMasterPasswordThrows_thenAlertIsShown() {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have window")
            return
        }
        window.rootViewController = vc
        window.makeKeyAndVisible()
        account.setMasterPasswordThrows = true
        vc.textInputDidReturn()
        wait()
        XCTAssertNotNil(vc.presentedViewController)
        XCTAssertTrue(vc.presentedViewController is UIAlertController)
    }

    func test_whenTerminated_thenCallsDelegate() {
        vc.terminate()
        XCTAssertTrue(delegate.didTerminate)
    }

}

class MockConfirmPasswordViewControllerDelegate: ConfirmPasswordViewControllerDelegate {

    var didConfirm = false
    var didTerminate = false

    func didConfirmPassword() {
        didConfirm = true
    }

    func terminate() {
        didTerminate = true
    }

}
