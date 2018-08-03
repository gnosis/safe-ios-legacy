//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt
import CommonTestSupport

class TransactionReviewViewControllerTests: XCTestCase {

    let service = MockWalletApplicationService()
    let vc = TransactionReviewViewController.create()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
    }

    func test_whenLoaded_thenTakesDataFromTransaction() {
        let sender = "0x8f51473aa98096145a9cadc421e4d33833e47365"
        let recipient = "0xFe2149773B3513703E79Ad23D05A778A185016ee"
        let amount = "0,1 ETH"
        let balance = "1 ETH"
        let id = "some"
        let fee = "-0,01 ETH"

        service.update(account: "ETH", newBalance: Int(BigInt(10).power(18)))

        service.transactionData_output = TransactionData(id: id,
                                                         sender: sender,
                                                         recipient: recipient,
                                                         amount: BigInt(10).power(17),
                                                         token: "ETH",
                                                         fee: BigInt(10).power(16))


        let vc = TransactionReviewViewController.create()
        vc.transactionID = id
        vc.loadViewIfNeeded()

        XCTAssertEqual(vc.senderView.address, sender)

        XCTAssertEqual(vc.recipientView.address, recipient)

        XCTAssertTrue(vc.transactionValueView.isSingleValue)
        XCTAssertEqual(vc.transactionValueView.tokenAmount, amount)

        XCTAssertEqual(vc.safeBalanceValueLabel.text, balance)
        XCTAssertEqual(vc.feeValueLabel.text, fee)
        XCTAssertTrue(vc.dataInfoStackView.isHidden)
    }

    func test_whenLoaded_thenLocksTransaction() {
        service.createReadyToUseWallet()
        vc.transactionID = "some"
        service.transactionData_output = TransactionData(id: "some",
                                                         sender: "some",
                                                         recipient: "some",
                                                         amount: 100,
                                                         token: "ETH",
                                                         fee: 0)
        service.requestTransactionConfirmation_output = TransactionData(id: "some",
                                                                        sender: "some",
                                                                        recipient: "some",
                                                                        amount: 100,
                                                                        token: "ETH",
                                                                        fee: BigInt(10).power(18))

        vc.loadViewIfNeeded()
        delay()
        XCTAssertEqual(service.requestTransactionConfirmation_input, "some")
        XCTAssertEqual(vc.feeValueLabel.text, "-1 ETH")
    }

}
