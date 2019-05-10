//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common
import CommonTestSupport

class PaymentMethodViewControllerTests: SafeTestCase {

    let controller = PaymentMethodViewController()

    override func setUp() {
        super.setUp()
        walletService.paymentTokensOutput = [TokenData.eth, TokenData.gno, TokenData.mgn]
    }

    func test_whenCreated_thenLoadsData() {
        createWindow(controller)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 3)
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, MenuTrackingEvent.feePaymentMethod)
    }

    func test_whenUpdatesBalances_thenSync() {
        controller.updateBalances()
        delay(0.1)
        XCTAssertTrue(walletService.didSync)
    }

    func test_whenSelectingRow_thenChangesPaymentToken() {
        XCTAssertNil(walletService.changedPaymentToken)
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssertNotNil(walletService.changedPaymentToken)
    }

}
