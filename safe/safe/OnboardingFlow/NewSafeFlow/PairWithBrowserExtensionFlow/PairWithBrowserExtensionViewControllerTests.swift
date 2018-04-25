//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessApplication

class PairWithBrowserExtensionViewControllerTests: SafeTestCase {

    // swiftlint:disable weak_delegate
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
        controller.viewDidLoad()
        XCTAssertTrue(controller.extensionAddressInput.qrCodeDelegate === controller)
        XCTAssertFalse(controller.finishButton.isEnabled)
    }

    func test_presentScannerController() {
        createWindow(controller)
        let presentedController = UIViewController()
        controller.presentScannerController(presentedController)
        XCTAssertTrue(controller.presentedViewController === presentedController)
    }

    func test_didScanValidCode_makesFinishButtonEnabled() {
        controller.viewDidLoad()
        controller.didScanValidCode()
        XCTAssertTrue(controller.finishButton.isEnabled)
    }

    func test_finish_whenNoAddress_thenLogsError() {
        controller.finish(self)
        XCTAssertFalse(delegate.paired)
        XCTAssertTrue(logger.errorLogged)
    }

    func test_finish_whenAddressIsThere_thenCallsDelegate() {
        controller.extensionAddressInput.text = "test_address"
        controller.finish(self)
        XCTAssertEqual(controller.extensionAddressInput.text, delegate.address)
        XCTAssertTrue(delegate.paired)
    }

}

class MockPairWithBrowserDelegate: PairWithBrowserDelegate {

    var paired = false
    var address = ""

    func didPair(_ extensionAddress: String) {
        paired = true
        address = extensionAddress
    }

}
