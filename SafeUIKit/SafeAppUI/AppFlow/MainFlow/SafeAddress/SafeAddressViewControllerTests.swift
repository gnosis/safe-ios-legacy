//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import CommonTestSupport

class SafeAddressViewControllerTests: XCTestCase {

    let walletService = MockWalletApplicationService()
    let testAddress = "test_address"
    var controller: SafeAddressViewController!

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        walletService.assignAddress(testAddress)
        controller = SafeAddressViewController.create()
    }

    func test_whenCreated_thenDisplaysCorrectData() {
        createWindow(controller)
        controller.viewDidLoad()
        XCTAssertEqual(controller.safeAddressLabel.address, testAddress)
        XCTAssertEqual(controller.qrCodeView.value, testAddress)
        XCTAssertEqual(controller.identiconView.seed, testAddress)
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, MainTrackingEvent.receiveFunds)
    }
}
