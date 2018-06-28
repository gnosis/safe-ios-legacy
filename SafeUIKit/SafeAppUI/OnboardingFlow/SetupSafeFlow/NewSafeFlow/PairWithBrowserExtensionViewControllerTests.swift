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
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertTrue(controller.delegate === delegate)
    }

    func test_viewDidLoad() {
        XCTAssertTrue(controller.extensionAddressInput.qrCodeDelegate === controller)
        XCTAssertEqual(controller.extensionAddressInput.editingMode, .scanOnly)
    }

    func test_viewDidLoad_whenNoInitialAddress_thenSaveButtonIsDisabled() {
        XCTAssertFalse(controller.saveButton.isEnabled)
    }

    func test_viewDidLoad_whenInitialAddressProvided_thenSaveButtonIsEnabled() {
        walletService.addOwner(address: "address", type: .browserExtension)
        controller = PairWithBrowserExtensionViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
        XCTAssertTrue(controller.saveButton.isEnabled)
    }

    func test_presentScannerController() {
        createWindow(controller)
        let presentedController = UIViewController()
        controller.presentScannerController(presentedController)
        XCTAssertTrue(controller.presentedViewController === presentedController)
    }

    func test_didScanValidCode_makesSaveButtonEnabled() {
        controller.didScanValidCode("code")
        XCTAssertTrue(controller.saveButton.isEnabled)
    }

    func test_didScanValidCode_dismissesScannerController() {
        createWindow(controller)
        let presentedController = UIViewController()
        controller.presentScannerController(presentedController)
        delay(1)
        controller.didScanValidCode("code")
        delay(1)
        XCTAssertFalse(controller.presentedViewController === presentedController)
    }

    func test_invalidCode_presentsAlert() {
        createWindow(controller)
        let presentedController = UIAlertController(title: "some", message: "ok", preferredStyle: .alert)
        controller.presentCameraRequiredAlert(presentedController)
        XCTAssertTrue(controller.presentedViewController === presentedController)
    }

    func test_finish_whenNoAddress_thenLogsError() {
        controller.finish(self)
        XCTAssertFalse(delegate.paired)
        XCTAssertTrue(logger.errorLogged)
    }

    func test_finish_whenAddressIsThere_thenCallsDelegate() {
        controller.extensionAddressInput.text = "test_address"
        controller.didScanValidCode("code")
        controller.finish(self)
        delay()
        XCTAssertTrue(delegate.paired)
    }

    func test_whenFinishing_thenCreatesOwner() throws {
        try walletService.createNewDraftWallet()
        controller.extensionAddressInput.text = "address"
        controller.didScanValidCode("code")
        controller.finish(self)
        delay()
        XCTAssertTrue(walletService.isOwnerExists(.browserExtension))
    }

}

class MockPairWithBrowserDelegate: PairWithBrowserDelegate {

    var paired = false
    var address = ""

    func didPair() {
        paired = true
        address = "address"
    }

}
