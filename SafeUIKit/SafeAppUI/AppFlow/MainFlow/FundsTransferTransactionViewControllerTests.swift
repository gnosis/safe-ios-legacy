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
        XCTAssertEqual(controller.feeLabel.text, "--")
    }

    func test_whenLoaded_thenEstimatesTransactionFee() {
        walletService.estimatedFee_output = 100
        controller.loadViewIfNeeded()
        delay()
        XCTAssertEqual(controller.feeLabel.text, "-0,0000000000000001 ETH")
    }

    func test_whenInvalidAmount_thenShowsError() {
        controller.loadViewIfNeeded()
        controller.amountTextField.text = ""
        _ = controller.amountTextField.delegate?.textField?(controller.amountTextField,
                                                            shouldChangeCharactersIn: NSRange(),
                                                            replacementString: "")
        XCTAssertGreaterThan(controller.amountStackView.arrangedSubviews.count, 1)
    }

    func test_whenInvalidAddress_thenShowsError() {
        controller.loadViewIfNeeded()
        controller.recipientTextField.text = ""
        _ = controller.recipientTextField.delegate?.textField?(controller.recipientTextField,
                                                               shouldChangeCharactersIn: NSRange(),
                                                               replacementString: "")
        XCTAssertGreaterThan(controller.recipientStackView.arrangedSubviews.count, 1)
    }

    func test_whenClearsText_thenRemovesError() {
        test_whenInvalidAmount_thenShowsError()
        _ = controller.amountTextField.delegate?.textFieldShouldClear?(controller.amountTextField)
        XCTAssertEqual(controller.amountStackView.arrangedSubviews.count, 1)
    }

}
