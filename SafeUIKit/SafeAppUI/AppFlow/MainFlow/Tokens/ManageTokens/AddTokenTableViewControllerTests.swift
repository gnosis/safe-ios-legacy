//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import Common
import SafeUIKit

class AddTokenTableViewControllerTests: XCTestCase {

    var controller: AddTokenTableViewController!
    let walletService = MockWalletApplicationService()
    // swiftlint:disable:next weak_delegate
    let delegate = MockAddTokenTableViewControllerDelegate()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        walletService.tokensOutput = [TokenData.gno, TokenData.gno2, TokenData.mgn, TokenData.rdn]
        controller = AddTokenTableViewController()
        controller.delegate = delegate
    }

    func test_whenCreated_thenLoadsData() {
        createWindow(controller)
        XCTAssertEqual(controller.tableView.numberOfSections, 3)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 2)

        let firstCell = cell(at: 0, 0)
        XCTAssertEqual(firstCell.tokenCodeLabel.text, "GNO (Gnosis)")
        XCTAssertNil(firstCell.tokenBalanceLabel.text)

        let secondCell = cell(at: 0, 1)
        XCTAssertEqual(secondCell.tokenCodeLabel.text, "MGN (Magnolia)")

        let thirdCell = cell(at: 0, 2)
        XCTAssertEqual(thirdCell.tokenCodeLabel.text, "RDN (Raiden)")
    }

    func test_whenCellIsSelected_thenDelegateIsCalled() {
        selectSell(at: 0, 0)
        XCTAssertTrue(delegate.didSelect)
        XCTAssertEqual(delegate.didSelectToken_input!, TokenData.gno)
    }

    func test_whenViewForHeaderIsCalled_thenReturnsProperView() {
        let view = controller.tableView(controller.tableView, viewForHeaderInSection: 0)
        XCTAssertTrue(view is AddTokenHeaderView)
    }

    func test_whenHeightForHeaderIsCalled_thenRetuensProperHeight() {
        let height = controller.tableView(controller.tableView, heightForHeaderInSection: 0)
        XCTAssertEqual(height, AddTokenHeaderView.height)
    }

}


private extension AddTokenTableViewControllerTests {

    func cell(at row: Int, _ section: Int) -> TokenBalanceTableViewCell {
        return controller.tableView.cellForRow(at: IndexPath(row: row, section: section)) as! TokenBalanceTableViewCell
    }

    func selectSell(at row: Int, _ section: Int) {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: row, section: section))
    }

}

class MockAddTokenTableViewControllerDelegate: AddTokenTableViewControllerDelegate {

    var didSelect = false
    var didSelectToken_input: TokenData?
    func didSelectToken(_ tokenData: TokenData) {
        didSelect = true
        didSelectToken_input = tokenData
    }

}
