//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt
import CommonTestSupport

class FundsTransferTransactionViewControllerTests: XCTestCase {

    let walletService = MockWalletApplicationService()
    let walletAddress = "0x1CBFf6551B8713296b0604705B1a3B76D238Ae14"
    let balance = BigInt(1_000)
    let controller = FundsTransferTransactionViewController.create()

    override func setUp() {
        super.setUp()
        walletService.assignAddress(walletAddress)
        walletService.update(account: "ETH", newBalance: Int(balance))
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
    }

    func test_whenLoaded_thenShowsBalance() {
        controller.loadViewIfNeeded()
        XCTAssertEqual(controller.participantView.address, walletAddress)
        XCTAssertEqual(controller.participantView.name, "Safe")
        XCTAssertEqual(controller.valueView.tokenAmount, "0,000000000000001 ETH")
        XCTAssertEqual(controller.valueView.fiatAmount, "")
        XCTAssertEqual(controller.balanceLabel.text, controller.valueView.tokenAmount)
        XCTAssertEqual(controller.feeLabel.text, "n/a")
    }

    func test_whenLoaded_thenEstimatesTransactionFee() {
        walletService.estimatedFee_output = 100
        controller.loadViewIfNeeded()
        delay()
        XCTAssertEqual(controller.feeLabel.text, "-0,0000000000000001 ETH")
    }

    func test_whenChangingData_thenEstimateReloads() {
        controller.loadViewIfNeeded()
        assertEstimateReloadsForChangesIn(controller.amountTextField)
        assertEstimateReloadsForChangesIn(controller.recipientTextField)
    }

    private func assertEstimateReloadsForChangesIn(_ textField: UITextField, line: UInt = #line) {
        delay()
        walletService.estimatedFee_output = 100
        _ = textField.delegate?.textField?(textField,
                                           shouldChangeCharactersIn: NSRange(),
                                           replacementString: "1")
        delay()
        XCTAssertEqual(controller.feeLabel.text, "-0,0000000000000001 ETH", line: line)
    }

}
