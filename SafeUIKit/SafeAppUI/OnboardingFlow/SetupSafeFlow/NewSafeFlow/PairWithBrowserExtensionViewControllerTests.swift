//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import CommonTestSupport

class PairWithBrowserExtensionViewControllerTests: SafeTestCase {

    // swiftlint:disable:next weak_delegate
    let delegate = MockPairWithBrowserDelegate()
    var controller: PairWithBrowserExtensionViewController!

    override func setUp() {
        super.setUp()
        controller = PairWithBrowserExtensionViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
        ethereumService.browserExtensionAddress = "address"
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertTrue(controller.delegate === delegate)
    }

    func test_canPresentController() {
        createWindow(controller)
        let presentedController = UIViewController()
        controller.presentController(presentedController)
        XCTAssertTrue(controller.presentedViewController === presentedController)
    }

    func test_whenScansValidCode_thenAddsBowserExtension() {
        XCTAssertFalse(walletService.isOwnerExists(.browserExtension))
        controller.didScanValidCode(controller.scanBarButtonItem, code: "valid_code")
        delay()
        XCTAssertTrue(walletService.isOwnerExists(.browserExtension))
    }

    func test_whenScansValidCode_thenCallsTheDelegare() {
        controller.didScanValidCode(controller.scanBarButtonItem, code: "valid_code")
        delay()
        XCTAssertTrue(delegate.paired)
    }

    func test_whenWalletServiceThrows_thenAlertIsShown() {
        walletService.shouldThrow = true
        controller.didScanValidCode(controller.scanBarButtonItem, code: "valid_code")
        delay()
        XCTAssertAlertShown(message: PairWithBrowserExtensionViewController.Strings.invalidCode)
    }

}

class MockPairWithBrowserDelegate: PairWithBrowserDelegate {

    var paired = false
    func didPair() {
        paired = true
    }

}
