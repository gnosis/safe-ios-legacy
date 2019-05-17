//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import CommonTestSupport
import Common
import SafeUIKit

class TokensTableViewControllerTests: SafeTestCase {

    let controller = TokensTableViewController()

    override func setUp() {
        super.setUp()
        walletService.visibleTokensOutput = [TokenData.eth, TokenData.gno, TokenData.mgn]
    }

    func test_whenCreated_thenLoadsData() {
        createWindow(controller)
        controller.notify()
        delay()
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 2)
        let firstCell = cell(at: 0, 0)
        let secondCell = cell(at: 0, 1)
        let thirdCell = cell(at: 1, 1)
        XCTAssertEqual(firstCell.leftTextLabel.text, "ETH")
        XCTAssertEqual(firstCell.rightTextLabel.text?.replacingOccurrences(of: ",", with: "."), "0.01")
        XCTAssertEqual(secondCell.leftTextLabel.text, "GNO")
        XCTAssertEqual(secondCell.rightTextLabel.text?.replacingOccurrences(of: ",", with: "."), "1")
        XCTAssertEqual(thirdCell.leftTextLabel.text, "MGN")
        XCTAssertEqual(thirdCell.rightTextLabel.text, "--")
    }

    func test_whenUpdated_thenSyncs() {
        controller.update()
        delay(0.1)
        XCTAssertTrue(walletService.didSync)
    }

    func test_whenSelectingRow_thenCallsDelegate() {
        let delegate = MockMainViewControllerDelegate()
        controller.delegate = delegate
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(delegate.didCallCreateNewTransaction)
    }

    func test_whenThereAreNoTokens_thenTokensFooterIsShown() {
        walletService.visibleTokensOutput = [TokenData.eth]
        createWindow(controller)
        controller.notify()
        let footer = controller.tableView(controller.tableView, viewForFooterInSection: 1)
        XCTAssertTrue(footer is AddTokenFooterView)
    }

    func test_whenCreatingHeader_thenDequeuesIt() {
        createWindow(controller)
        controller.notify()
        let footer = controller.tableView(controller.tableView, viewForHeaderInSection: 1)
        XCTAssertTrue(footer is TokensHeaderView)
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, MainTrackingEvent.assets)
    }

}

private extension TokensTableViewControllerTests {

    func cell(at row: Int, _ section: Int) -> BasicTableViewCell {
        return controller.tableView.cellForRow(at: IndexPath(row: row, section: section)) as! BasicTableViewCell
    }

}
