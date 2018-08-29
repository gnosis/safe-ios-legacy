//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication

class ManageTokensTableViewControllerTests: XCTestCase {

    var controller: ManageTokensTableViewController!
    let walletService = MockWalletApplicationService()
    // swiftlint:disable:next weak_delegate
    let delegate = MockManageTokensTableViewControllerDelegate()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        walletService.visibleTokensOutput = [TokenData.gno, TokenData.gno2, TokenData.mgn, TokenData.rdn]
        controller = ManageTokensTableViewController()
        controller.delegate = delegate
    }

    func test_whenEndsEditing_thenCallsDelegate() {
        controller.setEditing(false, animated: false)
        XCTAssertTrue(delegate.didEndEditing)
        XCTAssertEqual(delegate.endEditing_input, walletService.visibleTokensOutput)
    }

    func test_whenAddsToken_thenCallsDelegate() {
        controller.addToken()
        XCTAssertTrue(delegate.didAddToken)
    }

    func test_whenRowsMoved_thenTokensAreSwapped() {
        moveRow(from: 0, to: 2)
        controller.setEditing(false, animated: false)
        XCTAssertEqual(delegate.endEditing_input, [TokenData.gno2, TokenData.mgn, TokenData.gno, TokenData.rdn])

        moveRow(from: 3, to: 0)
        controller.setEditing(false, animated: false)
        XCTAssertEqual(delegate.endEditing_input, [TokenData.rdn, TokenData.gno2, TokenData.mgn, TokenData.gno])
    }

}

private extension ManageTokensTableViewControllerTests {

    func moveRow(from: Int, to: Int) {
        controller.tableView(
            controller.tableView, moveRowAt: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0))
    }

}

class MockManageTokensTableViewControllerDelegate: ManageTokensTableViewControllerDelegate {

    var didAddToken = false
    func addToken() {
        didAddToken = true
    }

    var didEndEditing = false
    var endEditing_input: [TokenData]?
    func endEditing(tokens: [TokenData]) {
        didEndEditing = true
        endEditing_input = tokens
    }

}
