//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import CommonTestSupport

class PairWithBrowserExtensionViewControllerTests: SafeTestCase {

    var controller: PairWithBrowserExtensionViewController!
    var didPair = false

    override func setUp() {
        super.setUp()
        controller = PairWithBrowserExtensionViewController.create {
            self.didPair = true
        }
        controller.loadViewIfNeeded()
        ethereumService.browserExtensionAddress = "address"
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
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
        XCTAssertFalse(didPair)
        delay()
        XCTAssertTrue(didPair)
    }

    func test_whenWalletServiceThrows_thenAlertIsShown() {
        walletService.shouldThrow = true
        controller.didScanValidCode(controller.scanBarButtonItem, code: "valid_code")
        delay()
        XCTAssertAlertShown(message: PairWithBrowserExtensionViewController.Strings.invalidCode)
    }

}
