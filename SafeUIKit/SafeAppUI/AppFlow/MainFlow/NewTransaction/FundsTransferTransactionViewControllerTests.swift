//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt
import CommonTestSupport
import Common

class FundsTransferTransactionViewControllerTests: XCTestCase {

    let walletService = MockWalletApplicationService()
    let walletAddress = "0x1CBFf6551B8713296b0604705B1a3B76D238Ae14"
    let balance = BigInt(1_000)
    var controller: FundsTransferTransactionViewController!

    override func setUp() {
        super.setUp()
        controller = FundsTransferTransactionViewController.create(tokenID: ethID)
        walletService.assignAddress(walletAddress)
        walletService.update(account: ethID, newBalance: balance)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
    }

    func test_whenProceedingToSigning_thenCreatesNewDraftTransaction_andUpdatesIt() {
        let transactionID = "TxID"
        let amount = BigInt(10).power(17)
        let balance = BigInt(10).power(18)
        let recipient = walletAddress
        walletService.update(account: ethID, newBalance: balance)
        walletService.estimatedFee_output = 100
        walletService.createNewDraftTransaction_output = transactionID

        let delegate = MockFundsTransferDelegate()

        controller.delegate = delegate
        controller.loadViewIfNeeded()
        controller.tokenInput.text = "0.1"
        controller.addressInput.text = recipient
        controller.proceedToSigning(controller.nextBarButton as Any)

        XCTAssertEqual(walletService.updateTransaction_input?.id, transactionID)
        XCTAssertEqual(delegate.didCreateDraftTransaction_input, transactionID)
        XCTAssertEqual(controller.transactionID, transactionID)
        XCTAssertEqual(walletService.updateTransaction_input?.amount, amount)
        XCTAssertEqual(walletService.updateTransaction_input?.recipient, recipient)
    }

    func test_whenControllerWillBeRemoved_thenDraftTransactionRemoved() {
        controller.transactionID = "some"
        walletService.expect_removeDraftTransaction("some")
        controller.willBeRemoved()
        delay()
        XCTAssertTrue(walletService.verify())
    }

    func test_tracking() {
        XCTAssertTracks { handler in
            controller.loadViewIfNeeded()
            controller.viewDidAppear(false)

            let screenName = SendTrackingEvent.ScreenName.input.rawValue
            let tokenAddress = TokenData.Ether.address
            let tokenName = TokenData.Ether.code
            let eventName = Tracker.screenViewEventName

            XCTAssertEqual(handler.events[0].name, eventName)
            XCTAssertEqual(handler.parameter(at: 0, name: Tracker.screenNameEventParameterName), screenName)
            XCTAssertEqual(handler.parameter(at: 0, name: SendTrackingEvent.tokenParameterName), tokenAddress)
            XCTAssertEqual(handler.parameter(at: 0, name: SendTrackingEvent.tokenNameParameterName), tokenName)
        }
    }

}

class MockFundsTransferDelegate: FundsTransferTransactionViewControllerDelegate {

    var didCreateDraftTransaction_input: String?

    func didCreateDraftTransaction(id: String) {
        didCreateDraftTransaction_input = id
    }

}
