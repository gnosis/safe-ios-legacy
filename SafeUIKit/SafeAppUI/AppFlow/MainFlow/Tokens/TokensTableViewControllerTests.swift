//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class TokensTableViewControllerTests: XCTestCase {

    let controller = TokensTableViewController.create()

    func test_whenCreated_thenLoadsDummyData() {
        createWindow(controller)
        XCTAssertGreaterThan(controller.tableView.numberOfRows(inSection: 0), 2)
        let firstCell = cell(at: 0)
        let secondCell = cell(at: 1)
        XCTAssertNotEqual(firstCell.tokenImageView.image, secondCell.tokenImageView.image)
        XCTAssertNotEqual(firstCell.tokenNameLabel.text, secondCell.tokenNameLabel.text)
        XCTAssertNotEqual(firstCell.tokenBalanceLabel.text, secondCell.tokenBalanceLabel.text)
        XCTAssertNotEqual(firstCell.fiatBalanceLabel.text, secondCell.fiatBalanceLabel.text)
    }

    func test_whenSelectingRow_thenDeselectsIt() {
        createWindow(controller)
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    func test_whenCreatingFooter_thenDequeuesIt() {
        createWindow(controller)
        let footer = controller.tableView(controller.tableView, viewForFooterInSection: 0)
        XCTAssertTrue(footer is AddTokenFooterView)
    }

    private func cell(at row: Int) -> TokenBalanceTableViewCell {
        return controller.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! TokenBalanceTableViewCell
    }

}
