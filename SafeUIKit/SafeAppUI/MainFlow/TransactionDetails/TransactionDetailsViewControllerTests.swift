//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import SafeUIKit
import MultisigWalletApplication
import Common

class TransactionDetailsViewControllerTests: XCTestCase {

    let service = MockWalletApplicationService()
    var controller: TransactionDetailsViewController!

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
        controller = TransactionDetailsViewController.create(transactionID: "some")
    }

    func test_whenTransactionDataProvided_thenPutsItOnTheScreen() {
        let tx = TransactionData.pending
        service.transactionData_output = tx
        controller.clock = TestClock()
        createWindow(controller)
        XCTAssertEqual(controller.transferView.fromAddress, tx.sender)
        XCTAssertEqual(controller.transferView.toAddress, tx.recipient)

        XCTAssertEqual(controller.transferView.tokenData, tx.amountTokenData)

        typealias Strings = TransactionDetailsViewController.Strings

        XCTAssertEqual(controller.transactionTypeView.name, Strings.type)
        XCTAssertEqual(controller.transactionTypeView.value, Strings.outgoingType)

        XCTAssertEqual(controller.submittedParameterView.name, Strings.submitted)
        XCTAssertEqual(controller.submittedParameterView.value, controller.string(from: tx.submitted!))

        XCTAssertEqual(controller.transactionStatusView.name, Strings.status)
        XCTAssertEqual(controller.transactionStatusView.status, .pending)
        XCTAssertEqual(controller.transactionStatusView.value, controller.string(from: tx.displayDate!))

        XCTAssertEqual(controller.transactionFeeView.amount,
                       tx.feeTokenData.withBalance(abs(tx.feeTokenData.balance!)))

        XCTAssertEqual(controller.viewInExternalAppButton.title(for: .normal), Strings.externalApp)
    }

    func test_whenTapsOnExternalApp_thenCallsDelegate() {
        service.transactionData_output = TransactionData.pending
        createWindow(controller)
        let delegate = TestTransactionDetailsViewControllerDelegate()
        controller.delegate = delegate
        delegate.expect_showTransactionInExternalApp(from: controller)
        controller.viewInExternalAppButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(delegate.verify())
    }

    func test_whenStatusChanging_thenStatusParameterStatusChanges() {
        // TODO: use allCases
        let txStatuses = [TransactionData.Status.rejected, .failed, .success, .pending,
                          .readyToSubmit, .waitingForConfirmation]
        let viewStatuses = [TransactionStatusParameter.rejected, .failed, .success, .pending,
                            .pending, .pending]
        zip(txStatuses, viewStatuses).forEach { txStatus, viewStatus in
            XCTAssertEqual(controller.statusViewStatus(from: txStatus), viewStatus)
        }
    }

    func test_whenLoaded_thenSubscribesForTxUpdates() {
        service.transactionData_output = .pending
        service.expect_subscribeForTransactionUpdates(subscriber: controller)
        controller.loadViewIfNeeded()
        XCTAssertTrue(service.verify())
    }

    func test_tracking() {
        service.transactionData_output = TransactionData.pending
        controller.loadViewIfNeeded()
        XCTAssertTracks { handler in
            controller.viewDidAppear(false)
            XCTAssertEqual(handler.screenName(at: 0), TransactionDetailTrackingEvent(type: .send).rawValue)
            XCTAssertEqual(handler.parameter(at: 0, name: TransactionDetailTrackingEvent.transactionTypeParameterName),
                           TransactionDetailType.send.rawValue)
        }
    }

}

class TestClock: ClockService {

    var frozenTime = Date()

    override var currentTime: Date { return frozenTime }

}

extension TransactionData {
    static let pending = TransactionData(id: "some",
                                         walletID: "0x674647242239941b2D35368e66A4EdC39b161Da9",
                                         sender: "0x674647242239941b2D35368e66A4EdC39b161Da9",
                                         senderName: nil,
                                         recipient: "0x97e3bA6cC43b2aF2241d4CAD4520DA8266170988",
                                         recipientName: nil,
                                         amountTokenData: TokenData.gno.withBalance(10_001),
                                         feeTokenData: TokenData.gno.withBalance(101),
                                         status: .pending,
                                         type: .outgoing,
                                         created: Date(),
                                         updated: Date(),
                                         submitted: Date(),
                                         rejected: nil,
                                         processed: nil)
}

class TestTransactionDetailsViewControllerDelegate: TransactionDetailsViewControllerDelegate {

    public var expected_showTransactionInExternalApp = [TransactionDetailsViewController]()
    public var actual_showTransactionInExternalApp = [TransactionDetailsViewController]()

    func expect_showTransactionInExternalApp(from controller: TransactionDetailsViewController) {
        expected_showTransactionInExternalApp.append(controller)
    }

    func showTransactionInExternalApp(from controller: TransactionDetailsViewController) {
        actual_showTransactionInExternalApp.append(controller)
    }

    func verify() -> Bool {
        return actual_showTransactionInExternalApp == expected_showTransactionInExternalApp
    }

}
