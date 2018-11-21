//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt
import Common
import SafeUIKit

class ReviewTransactionViewControllerTests: XCTestCase {

    let service = MockWalletApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
    }

    func test_whenLoaded_thenSetsTransactionHeaderAccordingToTransactionData() {
        let (data, vc) = ethDataAndCotroller()
        let headerCell = vc.cellForRow(0) as! TransactionHeaderCell
        XCTAssertEqual(headerCell.transactionHeaderView.assetCode, data.amountTokenData.code)
        XCTAssertEqual(headerCell.transactionHeaderView.assetInfo,
                       LocalizedString("transaction.outgoing_transfer", comment: ""))
    }

    func test_whenLoaded_thenSetsTransferViewAccordingToTransactionData() {
        let (data, vc) = ethDataAndCotroller()
        let transferViewCell = vc.cellForRow(1) as! TransferViewCell
        XCTAssertEqual(transferViewCell.transferView.fromAddress, data.sender)
        XCTAssertEqual(transferViewCell.transferView.toAddress, data.recipient)
        XCTAssertEqual(transferViewCell.transferView.tokenData, data.amountTokenData)
    }

    func test_whenLoadedForEtherTransfer_thenHasOneTransactionFeeCell() {
        let (_, vc) = ethDataAndCotroller()
        XCTAssertTrue(vc.cellForRow(3) is TransactionFeeCell)
        XCTAssertEqual(vc.cellsCount(), 4)
    }

    func test_whenLoadedForTokenTransfer_thenHasTwoTransactionFeeCells() {
        let (_, vc) = tokenDataAndCotroller()
        XCTAssertTrue(vc.cellForRow(3) is TransactionFeeCell)
        XCTAssertTrue(vc.cellForRow(4) is TransactionFeeCell)
        XCTAssertEqual(vc.cellsCount(), 5)
    }

}

private extension ReviewTransactionViewControllerTests {

    func ethDataAndCotroller() -> (TransactionData, ReviewTransactionViewController) {
        let data = TransactionData.ethData(status: .readyToSubmit)
        let vc = controller(for: data)
        return (data, vc)
    }

    func tokenDataAndCotroller() -> (TransactionData, ReviewTransactionViewController) {
        let data = TransactionData.tokenData(status: .readyToSubmit)
        let vc = controller(for: data)
        return (data, vc)
    }

    func controller(for data: TransactionData) -> ReviewTransactionViewController {
        service.transactionData_output = data
        service.update(account: BaseID(data.amountTokenData.address), newBalance: BigInt(10).power(19))
        let vc = ReviewTransactionViewController(transactionID: data.id)
        vc.viewDidLoad()
        return vc
    }

}

private extension ReviewTransactionViewController {

    func cellForRow(_ row: Int) -> UITableViewCell {
        return tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0))
    }

    func cellsCount() -> Int {
        return tableView(tableView, numberOfRowsInSection: 0)
    }

}

extension TransactionData {

    static func ethData(status: Status) -> TransactionData {
        return TransactionData(id: "some",
                               sender: "some",
                               recipient: "some",
                               amountTokenData: TokenData.Ether.copy(balance: BigInt(10).power(18)),
                               feeTokenData: TokenData.Ether.copy(balance: BigInt(10).power(17)),
                               status: status,
                               type: .outgoing,
                               created: nil,
                               updated: nil,
                               submitted: nil,
                               rejected: nil,
                               processed: nil)
    }

    static func tokenData(status: Status) -> TransactionData {
        return TransactionData(id: "some",
                               sender: "some",
                               recipient: "some",
                               amountTokenData: TokenData.gno.copy(balance: BigInt(10).power(18)),
                               feeTokenData: TokenData.gno.copy(balance: BigInt(10).power(17)),
                               status: status,
                               type: .outgoing,
                               created: nil,
                               updated: nil,
                               submitted: nil,
                               rejected: nil,
                               processed: nil)
    }

}
