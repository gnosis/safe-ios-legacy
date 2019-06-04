//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import CommonTestSupport

class ReceiveFundsViewControllerTests: XCTestCase {

    let walletService = MockWalletApplicationService()
    let testAddress = "test_address"
    var controller: ReceiveFundsViewController!

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        walletService.assignAddress(testAddress)
        controller = ReceiveFundsViewController.create()
        controller.loadViewIfNeeded()
    }

    func test_whenCreated_thenDisplaysCorrectData() {
        XCTAssertEqual(controller.addressDetailView.address, testAddress)
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, MainTrackingEvent.receiveFunds)
    }

}
