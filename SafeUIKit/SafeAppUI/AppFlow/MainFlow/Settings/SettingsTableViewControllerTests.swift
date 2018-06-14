//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class SettingsTableViewControllerTests: XCTestCase {

    let controller = SettingsTableViewController.create()

    override func setUp() {
        super.setUp()
        createWindow(controller)
    }

    func test_whenCreated_thenConfigured() {
        XCTAssertEqual(controller.tableView.numberOfSections, 3)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertGreaterThan(controller.tableView.numberOfRows(inSection: 1), 0)
        XCTAssertGreaterThan(controller.tableView.numberOfRows(inSection: 2), 0)
    }

    func test_whenSelectingCell_thenDeselectsIt() {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    func test_whenCreated_thenRowHeightsAreProvided() {
        XCTAssertGreaterThan(cellHeight(row: 0, section: 0), 44)
        XCTAssertGreaterThan(cellHeight(row: 0, section: 1), 44)
        XCTAssertGreaterThan(cellHeight(row: 0, section: 2), 44)
    }

    func test_whenGettingRow_thenCreatesAppropriateCell() {
        XCTAssertTrue(cell(row: 0, section: 0) is SelectedSafeTableViewCell)
        XCTAssertTrue(cell(row: 0, section: 1) is SafeTableViewCell)
        XCTAssertTrue(cell(row: 0, section: 2) is MenuItemTableViewCell)
    }

    func test_whenConfiguredSelectedSafeRow_thenAllIsThere() {
        let cell = self.cell(row: 0, section: 0) as! SelectedSafeTableViewCell
        XCTAssertNotNil(cell.safeNameLabel.text)
        XCTAssertNotNil(cell.safeAddressLabel.text)
        XCTAssertNotNil(cell.safeIconImageView.image)
    }

    func test_whenConfiguredSafeRow_thenAllSet() {
        let cell = self.cell(row: 0, section: 1) as! SafeTableViewCell
        XCTAssertNotNil(cell.safeNameLabel.text)
        XCTAssertNotNil(cell.safeAddressLabel.text)
        XCTAssertNotNil(cell.safeIconImageView.image)
    }

    func test_whenConfiguredMenuItemRow_thenAllSet() {
        let cell = self.cell(row: 0, section: 2) as! MenuItemTableViewCell
        XCTAssertNotNil(cell.itemNameLabel.text)
        XCTAssertNotNil(cell.menuIconImageView.image)
    }

}

extension SettingsTableViewControllerTests {

    private func cellHeight(row: Int, section: Int) -> CGFloat {
        return controller.tableView(controller.tableView, heightForRowAt: IndexPath(row: row, section: section))
    }

    private func cell(row: Int, section: Int) -> UITableViewCell {
        return controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: row, section: section))
    }

}
