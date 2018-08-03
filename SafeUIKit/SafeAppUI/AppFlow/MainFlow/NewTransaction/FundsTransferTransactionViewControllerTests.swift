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

    func test_whenProceedingToSigning_thenCreatesNewDraftTransaction_andUpdatesIt() {
        let transactionID = "TxID"
        let amount = BigInt(10).power(17)
        let balance = BigInt(10).power(18)
        let recipient = walletAddress
        walletService.update(account: "ETH", newBalance: Int(balance))
        walletService.estimatedFee_output = 100
        walletService.createNewDraftTransaction_output = transactionID

        let delegate = MockFundsTransferDelegate()

        controller.delegate = delegate
        controller.loadViewIfNeeded()
        controller.amountTextField.type("0,1")
        controller.recipientTextField.type(recipient)
        delay()
        controller.proceedToSigning(controller.continueButton)

        XCTAssertEqual(walletService.updateTransaction_input?.id, transactionID)
        XCTAssertEqual(delegate.didCreateDraftTransaction_input, transactionID)
        XCTAssertEqual(walletService.updateTransaction_input?.amount, amount)
        XCTAssertEqual(walletService.updateTransaction_input?.recipient, recipient)
    }
}

extension UITextField {

    func type(_ string: String) {
        let originalText = text ?? ""
        let shouldType = delegate?.textField?(self,
                                              shouldChangeCharactersIn: NSMakeRange(originalText.count, 0),
                                              replacementString: string) ?? true
        if shouldType {
            text = originalText + string
        }
    }

}

class MockFundsTransferDelegate: FundsTransferTransactionViewControllerDelegate {

    var didCreateDraftTransaction_input: String?

    func didCreateDraftTransaction(id: String) {
        didCreateDraftTransaction_input = id
    }

}
