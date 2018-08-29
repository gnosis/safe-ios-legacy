//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt

class AddTokenTableViewControllerTests: XCTestCase {

    var controller: AddTokenTableViewController!
    let walletService = MockWalletApplicationService()
    // swiftlint:disable:next weak_delegate
    let delegate = MockAddTokenTableViewControllerDelegate()

    let gnoTokenData = TokenData(
        address: "1", code: "GNO", name: "Gnosis", logoURL: "", decimals: 18, balance: BigInt(10e16))
    let gno2TokenData = TokenData(
        address: "2", code: "GNO2", name: "Gnosis2", logoURL: "", decimals: 18, balance: BigInt(10e16))
    let mgnTokenData = TokenData(
        address: "3", code: "MGN", name: "Magnolia", logoURL: "", decimals: 18, balance: nil)
    let rdnTokenData = TokenData(
        address: "4", code: "RDN", name: "Raiden", logoURL: "", decimals: 18, balance: BigInt(10e15))

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        walletService.tokensOutput = [gnoTokenData, gno2TokenData, mgnTokenData, rdnTokenData]
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
        XCTAssertEqual(delegate.didSelectToken_input!, gnoTokenData)
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
