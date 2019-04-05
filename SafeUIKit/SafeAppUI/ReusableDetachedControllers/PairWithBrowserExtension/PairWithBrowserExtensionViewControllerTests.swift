//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import CommonTestSupport

class PairWithBrowserExtensionViewControllerTests: SafeTestCase {

    var controller: PairWithBrowserExtensionViewController!
    //swiftlint:disable:next weak_delegate
    var testDelegate = TestPairWithBrowserExtensionViewControllerDelegate()

    override func setUp() {
        super.setUp()
        controller = PairWithBrowserExtensionViewController.create(delegate: testDelegate)
        controller.loadViewIfNeeded()
        ethereumService.browserExtensionAddress = "address"
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
    }

    func test_canPresentController() {
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

class TestPairWithBrowserExtensionViewControllerDelegate: PairWithBrowserExtensionViewControllerDelegate {

    var pairedAddress: String?
    var pairedCode: String?

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) throws {
        pairedAddress = address
        pairedCode = code
    }

    func pairWithBrowserExtensionViewControllerDidSkipPairing() {
    }

    func pairWithBrowserExtensionViewControllerDidFinish() {
    }

}
