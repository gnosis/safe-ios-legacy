//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt

class TokensTableViewControllerTests: XCTestCase {

    let controller = TokensTableViewController()
    let walletService = MockWalletApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        let ethTokenData = TokenData(code: "ETH",
                                     name: "Ether",
                                     logoURL: "https://google.com/",
                                     decimals: 18,
                                     balance: BigInt(10e15))
        let gnoTokenData = TokenData(code: "GNO",
                                     name: "Gnosis",
                                     logoURL: "https://google.com/",
                                     decimals: 18,
                                     balance: BigInt(10e16))
        let mgnTokenData = TokenData(code: "MGN",
                                     name: "Magnolia",
                                     logoURL: "https://google.com/",
                                     decimals: 18,
                                     balance: nil)
        walletService.tokensOutput = [ethTokenData, gnoTokenData, mgnTokenData]
    }

    func test_whenCreated_thenLoadsData() {
        createWindow(controller)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 3)
        let firstCell = cell(at: 0)
        let secondCell = cell(at: 1)
        let thirdCell = cell(at: 2)
        XCTAssertEqual(firstCell.tokenCodeLabel.text, "ETH")
        XCTAssertEqual(firstCell.tokenBalanceLabel.text?.replacingOccurrences(of: ",", with: "."), "0.01")
        XCTAssertEqual(secondCell.tokenCodeLabel.text, "GNO")
        XCTAssertEqual(secondCell.tokenBalanceLabel.text?.replacingOccurrences(of: ",", with: "."), "0.1")
        XCTAssertEqual(thirdCell.tokenCodeLabel.text, "MGN")
        XCTAssertEqual(thirdCell.tokenBalanceLabel.text, "--")
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
