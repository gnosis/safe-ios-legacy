//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class UnlockViewControllerTests: XCTestCase {

    var vc: UnlockViewController!
    let account = MockAccount()
    // swiftlint:disable weak_delegate
    let delegate = MockUnlockViewControllerDelegate()

    override func setUp() {
        super.setUp()
        vc = UnlockViewController.create(account: account, delegate: delegate)
        vc.loadViewIfNeeded()
    }

    func test_whenCreated_hasAllElements() {
        XCTAssertNotNil(vc.textInput)
        XCTAssertNotNil(vc.loginWithBiometryButton)
        XCTAssertNotNil(vc.headerLabel)
    }

    func test_whenAppeared_thenRequestsBiometricAuthentication() {
        vc.viewDidAppear(false)
        XCTAssertTrue(account.didRequestBiometricAuthentication)
    }

    func test_whenBiometrySuccess_thenCallsDelegate() {
        account.shouldAuthenticateImmediately = false
        vc.viewDidAppear(false)
        account.completeBiometryAuthentication(success: true)
        XCTAssertTrue(delegate.didLogInWasCalled)
    }

}

class MockUnlockViewControllerDelegate: UnlockViewControllerDelegate {

    var didLogInWasCalled = false

    func didLogIn() {
        didLogInWasCalled = true
    }

}
