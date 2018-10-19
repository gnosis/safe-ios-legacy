//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import SafeUIKit
import MultisigWalletApplication

class TransactionDetailsViewControllerTests: XCTestCase {

    let service = MockWalletApplicationService()
    var controller: TransactionDetailsViewController!

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
        controller = TransactionDetailsViewController.create(transactionID: "some")
    }

    func test_whenTransactionDataProvided_thenPutsItOnTheScreen() {
        let tx = TransactionData(id: "some",
                                 sender: "0x674647242239941b2D35368e66A4EdC39b161Da9",
                                 recipient: "0x97e3bA6cC43b2aF2241d4CAD4520DA8266170988",
                                 amount: 10_001,
                                 token: "GNO",
                                 tokenDecimals: 2,
                                 fee: 101,
                                 feeToken: "GNO",
                                 feeTokenDecimals: 2,
                                 status: .pending,
                                 type: .outgoing,
                                 created: Date(),
                                 updated: Date(),
                                 submitted: Date(),
                                 rejected: nil,
                                 processed: nil)
        service.transactionData_output = tx
        createWindow(controller)
        XCTAssertEqual(controller.senderView.address, tx.sender)
        XCTAssertEqual(controller.recipientView.address, tx.recipient)

        XCTAssertTrue(controller.transactionValueView.isSingleValue)
        XCTAssertEqual(controller.transactionValueView.style, .negative)
        let amountFormatter = TokenNumberFormatter.ERC20Token(code: tx.token, decimals: tx.tokenDecimals)
        XCTAssertEqual(controller.transactionValueView.tokenAmount, amountFormatter.string(from: tx.amount))

        typealias Strings = TransactionDetailsViewController.Strings

        XCTAssertEqual(controller.transactionTypeView.name, Strings.type)
        XCTAssertEqual(controller.transactionTypeView.value, Strings.outgoing)

        XCTAssertEqual(controller.submittedParameterView.name, Strings.submitted)
        XCTAssertEqual(controller.submittedParameterView.value, controller.string(from: tx.submitted!))

        XCTAssertEqual(controller.transactionStatusView.name, Strings.status)
        XCTAssertEqual(controller.transactionStatusView.status, .pending)
        XCTAssertEqual(controller.transactionStatusView.value, controller.string(from: tx.displayDate!))

        XCTAssertEqual(controller.transactionFeeView.name, Strings.fee)
        let feeFormatter = TokenNumberFormatter.ERC20Token(code: tx.feeToken, decimals: tx.feeTokenDecimals)
        XCTAssertEqual(controller.transactionFeeView.style, .negative)
        XCTAssertEqual(controller.transactionFeeView.value, feeFormatter.string(from: tx.fee))

        XCTAssertEqual(controller.viewInExternalAppButton.title(for: .normal), Strings.externalApp)
    }

}
