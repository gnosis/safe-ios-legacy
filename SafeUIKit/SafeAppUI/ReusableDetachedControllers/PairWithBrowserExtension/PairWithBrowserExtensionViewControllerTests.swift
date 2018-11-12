//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import CommonTestSupport

class PairWithBrowserExtensionViewControllerTests: SafeTestCase {

    var controller: PairWithBrowserExtensionViewController!
    var pairedAddress: String?
    var pairedCode: String?

    override func setUp() {
        super.setUp()
        controller = PairWithBrowserExtensionViewController.create { address, code in
            self.pairedAddress = address
            self.pairedCode = code
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

    func test_whenScansValidCode_thenCallsTheDelegare() {
        controller.didScanValidCode(controller.scanBarButtonItem, code: "valid_code")
        XCTAssertNil(pairedAddress)
        XCTAssertNil(pairedCode)
        delay()
        XCTAssertNotNil(pairedAddress)
        XCTAssertNotNil(pairedCode)
    }

}
