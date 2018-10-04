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

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        walletService.assignAddress(testAddress)
    }

    func test_whenCreated_thenDisplaysCorrectData() {
        let controller = SafeAddressViewController.create()
        createWindow(controller)
        controller.viewDidLoad()
        XCTAssertEqual(controller.safeAddressLabel.text, testAddress)
        XCTAssertEqual(controller.qrCodeView.value, testAddress)
        XCTAssertEqual(controller.identiconView.seed, testAddress)
    }

}
