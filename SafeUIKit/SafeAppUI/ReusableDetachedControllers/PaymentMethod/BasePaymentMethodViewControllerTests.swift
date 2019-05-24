//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common
import CommonTestSupport

class BasePaymentMethodViewControllerTests: SafeTestCase {

    let controller = BasePaymentMethodViewController()

    override func setUp() {
        super.setUp()
        controller.tokens = [TokenData.eth, TokenData.gno, TokenData.mgn, TokenData.mgn2]
    }

    func test_whenCreated_thenLoadsData() {
        createWindow(controller)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 4)
    }

    func test_whenSelectingRow_thenChangesPaymentToken() {
        XCTAssertNil(walletService.changedPaymentToken)
        selectRow(1) // gno with non-zero balance
        XCTAssertEqual(walletService.changedPaymentToken, TokenData.gno)
    }

    func test_whenSelectingTokenWithNoBance_thenDoesNothing() {
        selectRow(2) // mgn with nil balance
        XCTAssertNil(walletService.changedPaymentToken)
        selectRow(3) // mgn2 with zero balance
        XCTAssertNil(walletService.changedPaymentToken)
    }

    func test_whenUpdatingEstimations_thenSetsPaymentMethodEstimatedTokenData() {
        walletService.feePaymentTokenData_output = TokenData.mgn.withBalance(1)
        let estimation1 = TokenData.gno.withBalance(100)
        let estimation2 = TokenData.mgn.withBalance(100)
        controller.update(with: [estimation1, estimation2])
        XCTAssertEqual(controller.paymentToken, estimation2)
    }

    func test_whenEstimationsDoesNotContainSelectedPaymentMethod_thenSetsSelectedMethodToEth() {
        walletService.feePaymentTokenData_output = TokenData.mgn.withBalance(1)
        let estimation1 = TokenData.Ether.withBalance(100)
        let estimation2 = TokenData.gno.withBalance(100)
        controller.update(with: [estimation1, estimation2])
        XCTAssertEqual(controller.paymentToken, estimation1)
        XCTAssertEqual(walletService.feePaymentTokenData, TokenData.Ether)
    }

    private func selectRow(_ row: Int) {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: row, section: 0))
    }

}
