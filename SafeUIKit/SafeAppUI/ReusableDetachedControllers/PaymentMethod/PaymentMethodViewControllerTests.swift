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
        controller.viewDidLoad()
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, MenuTrackingEvent.feePaymentMethod)
    }

    func test_whenUpdatesBalances_thenSync() {
        controller.updateBalances()
        delay(0.1)
        XCTAssertTrue(walletService.didSync)
    }

    // TODO: fix ios 13
    func _test_whenSelectingDescriptionInHeader_thenShowsAlert() {
        createWindow(controller)
        let headerView = controller.tableView(controller.tableView,
                                              viewForHeaderInSection: 0) as! PaymentMethodHeaderView
        headerView.onTextSelected!()
        XCTAssertAlertShown()
    }

}
