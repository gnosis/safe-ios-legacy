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
        walletService.paymentTokensOutput = [TokenData.eth, TokenData.gno, TokenData.mgn, TokenData.mgn2]
    }

    func test_whenCreated_thenLoadsData() {
        createWindow(controller)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 4)
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
        selectRow(1) // gno with non-zero balance
        XCTAssertNotNil(walletService.changedPaymentToken)
    }

    func test_whenSelectingTokenWithNoBance_thenDoesNothing() {
        selectRow(2) // mgn with nil balance
        XCTAssertNil(walletService.changedPaymentToken)
        selectRow(3) // mgn2 with zero balance
        XCTAssertNil(walletService.changedPaymentToken)
    }

    func test_whenSelectingDescriptionInHeadr_thenShowsAlert() {
        createWindow(controller)
        let headerView = controller.tableView(controller.tableView,
                                              viewForHeaderInSection: 0) as! PaymentMethodHeaderView
        headerView.onTextSelected!()
        XCTAssertAlertShown(message: PaymentMethodViewController.Strings.Alert.description, actionCount: 1)
    }

    private func selectRow(_ row: Int) {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: row, section: 0))
    }

}
