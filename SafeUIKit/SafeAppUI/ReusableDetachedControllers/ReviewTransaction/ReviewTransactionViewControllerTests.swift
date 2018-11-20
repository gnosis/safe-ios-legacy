//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt
import Common

class ReviewTransactionViewControllerTests: XCTestCase {

    let service = MockWalletApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
    }

    func test_whenLoaded_thenSetsTransactionHeaderAccordingToTransactionData() {
        let data = TransactionData.create1(status: .readyToSubmit)
        service.transactionData_output = data
        let vc = ReviewTransactionViewController(transactionID: data.id)
        vc.loadViewIfNeeded()
        let headerCell = vc.cellForRow(0) as! TransactionHeaderCell
        XCTAssertEqual(headerCell.transactionHeaderView.assetCode, data.token)
        XCTAssertEqual(headerCell.transactionHeaderView.assetInfo,
                       LocalizedString("transaction.outgoing_transfer", comment: ""))
    }

}

private extension ReviewTransactionViewController {

    func cellForRow(_ row: Int) -> UITableViewCell {
        return tableView.cellForRow(at: IndexPath(row: row, section: 0))!
    }

}

extension TransactionData {

    // TODO: rename when finish refactoring
    static func create1(status: Status) -> TransactionData {
        return TransactionData(id: "some",
                               sender: "some",
                               recipient: "some",
                               amount: 100,
                               token: "ETH",
                               tokenDecimals: 18,
                               tokenLogoUrl: "",
                               fee: BigInt(10).power(18),
                               feeToken: "ETH",
                               feeTokenDecimals: 18,
                               status: status,
                               type: .outgoing,
                               created: nil,
                               updated: nil,
                               submitted: nil,
                               rejected: nil,
                               processed: nil)
    }

}
