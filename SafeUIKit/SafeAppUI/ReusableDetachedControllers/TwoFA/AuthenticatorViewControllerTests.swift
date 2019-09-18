//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import CommonTestSupport

class AuthenticatorViewControllerTests: SafeTestCase {

    var controller: AuthenticatorViewController!
    //swiftlint:disable:next weak_delegate
    var testDelegate = TestAuthenticatorViewControllerDelegate()

    override func setUp() {
        super.setUp()
        controller = AuthenticatorViewController.create(delegate: testDelegate)
        controller.loadViewIfNeeded()
        ethereumService.browserExtensionAddress = "address"
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
    }

    // TODO: ios 13
    func _test_canPresentController() {
        createWindow(controller)
        let presentedController = UIViewController()
        controller.scanBarButtonItemWantsToPresentController(presentedController)
        XCTAssertTrue(controller.presentedViewController === presentedController)
    }

    func test_whenScansValidCode_thenCallsTheDelegate() {
        XCTAssertNil(testDelegate.pairedAddress)
        XCTAssertNil(testDelegate.pairedCode)
        controller.scanBarButtonItemDidScanValidCode("valid_code")
        delay()
        XCTAssertNotNil(testDelegate.pairedAddress)
        XCTAssertNotNil(testDelegate.pairedCode)
    }

    func test_trackingAppearance() {
        controller.screenTrackingEvent = TestScreenTrackingEvent.view
        XCTAssertTracksAppearance(in: controller, TestScreenTrackingEvent.view)
    }

    func test_whenScansValidCode_thenTracksSuccess() {
        XCTAssertTracks { handler in
            controller.scanBarButtonItemDidScanValidCode("valid_code")
            delay()
            XCTAssertEqual(handler.screenName(at: 0), OnboardingTrackingEvent.twoFAScanSuccess.rawValue)
        }
    }

    func test_whenOpensCamera_thenTracksScan() {
        controller.scanTrackingEvent = TestScreenTrackingEvent.view
        XCTAssertTracks { handler in
            controller.scanBarButtonItemWantsToPresentController(UIViewController())
            XCTAssertEqual(handler.screenName(at: 0), TestScreenTrackingEvent.view.rawValue)
        }
    }

}

class TestAuthenticatorViewControllerDelegate: AuthenticatorViewControllerDelegate {

    var pairedAddress: String?
    var pairedCode: String?

    func authenticatorViewController(_ controller: AuthenticatorViewController, didScanAddress address: String, code: String) throws {
        pairedAddress = address
        pairedCode = code
    }

    func authenticatorViewControllerDidSkipPairing() {}

    func authenticatorViewControllerDidFinish() {}

    func didSelectOpenAuthenticatorInfo() {}

}
