//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class TransactionsTableViewControllerTests: XCTestCase {

    let controller = TransactionsTableViewController.create()

    func test_hasContent() {
        createWindow(controller)
        XCTAssertGreaterThan(controller.tableView.numberOfSections, 0)
        XCTAssertGreaterThan(controller.tableView.numberOfRows(inSection: 0), 1)
        let firstCell = cell(at: 0)
        XCTAssertNotNil(firstCell.transactionIconImageView.image)
        XCTAssertNotNil(firstCell.transactionTypeIconImageView.image)
        XCTAssertNotNil(firstCell.transactionDescriptionLabel.text)
        XCTAssertNotNil(firstCell.transactionDateLabel.text)
        XCTAssertNotNil(firstCell.fiatAmountLabel.text)
        XCTAssertNotNil(firstCell.tokenAmountLabel.text)
        XCTAssertFalse(firstCell.pairValueStackView.isHidden)
        XCTAssertNil(firstCell.singleValueLabel.text)
        XCTAssertTrue(firstCell.singleValueLabelStackView.isHidden)
        XCTAssertNotNil(firstCell.progressView)
        XCTAssertGreaterThan(firstCell.progressView.progress, 0)
        XCTAssertFalse(firstCell.progressView.isHidden)
    }

    func test_whenSelectingRow_thenDeselectsIt() {
        createWindow(controller)
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    private func cell(at row: Int) -> TransactionTableViewCell {
        return controller.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! TransactionTableViewCell
    }

}
