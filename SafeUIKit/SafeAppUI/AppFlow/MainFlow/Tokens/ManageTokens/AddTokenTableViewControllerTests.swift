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

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        let gnoTokenData = TokenData(code: "GNO", name: "Gnosis", logoURL: "", decimals: 18, balance: BigInt(10e16))
        let gno2TokenData = TokenData(code: "GNO2", name: "Gnosis2", logoURL: "", decimals: 18, balance: BigInt(10e16))
        let mgnTokenData = TokenData(code: "MGN", name: "Magnolia", logoURL: "", decimals: 18, balance: nil)
        let rdnTokenData = TokenData(code: "RDN", name: "Raiden", logoURL: "", decimals: 18, balance: BigInt(10e15))
        walletService.tokensOutput = [gnoTokenData, gno2TokenData, mgnTokenData, rdnTokenData]
        controller = AddTokenTableViewController()
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

    private func cell(at row: Int, _ section: Int) -> TokenBalanceTableViewCell {
        return controller.tableView.cellForRow(at: IndexPath(row: row, section: section)) as! TokenBalanceTableViewCell
    }

}
