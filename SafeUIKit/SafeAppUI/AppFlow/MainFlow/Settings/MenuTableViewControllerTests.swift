//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class MenuTableViewControllerTests: XCTestCase {

    let controller = MenuTableViewController.create()
    // swiftlint:disable:next weak_delegate
    let delegate = MockMenuTableViewControllerDelegate()

    override func setUp() {
        super.setUp()
        controller.delegate = delegate
        createWindow(controller)
    }

    func test_whenCreated_thenConfigured() {
        XCTAssertEqual(controller.tableView.numberOfSections, 4)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 2)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 3)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 2), 2)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 3), 1)
    }

    func test_whenCreated_thenRowHeightsAreProvided() {
        XCTAssertGreaterThan(cellHeight(row: 0, section: 0), 44)
        XCTAssertGreaterThan(cellHeight(row: 0, section: 1), 44)
        XCTAssertGreaterThan(cellHeight(row: 0, section: 2), 44)
    }

    func test_whenGettingRow_thenCreatesAppropriateCell() {
        XCTAssertTrue(cell(row: 0, section: 0) is SelectedSafeTableViewCell)
        XCTAssertTrue(cell(row: 0, section: 1) is MenuItemTableViewCell)
        XCTAssertTrue(cell(row: 0, section: 2) is MenuItemTableViewCell)
    }

    func test_whenConfiguredSelectedSafeRow_thenAllIsThere() {
        let cell = self.cell(row: 0, section: 0) as! SelectedSafeTableViewCell
        XCTAssertNotNil(cell.safeNameLabel.text)
        XCTAssertNotNil(cell.safeAddressLabel.text)
        XCTAssertNotNil(cell.safeIconImageView.image)
    }

    func test_whenConfiguredMenuItemRow_thenAllSet() {
        let cell = self.cell(row: 0, section: 2) as! MenuItemTableViewCell
        XCTAssertNotNil(cell.itemNameLabel.text)
        XCTAssertNil(cell.menuIconImageView.image)
    }

    // MARK: - Did select row

    func test_whenSelectingManageTokens_thenCallsDelegate() {
        selectCell(row: 1, section: 0)
        XCTAssertTrue(delegate.manageTokensSelected)
    }

    func test_whenSelectingCell_thenDeselectsIt() {
        selectCell(row: 0, section: 0)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

}

extension MenuTableViewControllerTests {

    private func cellHeight(row: Int, section: Int) -> CGFloat {
        return controller.tableView(controller.tableView, heightForRowAt: IndexPath(row: row, section: section))
    }

    private func cell(row: Int, section: Int) -> UITableViewCell {
        return controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: row, section: section))
    }

    private func selectCell(row: Int, section: Int) {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: row, section: section))
    }

}

final class MockMenuTableViewControllerDelegate: MenuTableViewControllerDelegate {

    var manageTokensSelected = false
    func didSelectManageTokens() {
        manageTokensSelected = true
    }

}
