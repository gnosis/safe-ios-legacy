//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import Common

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

    func test_whenAddsToken_thenCallsDelegate() {
        controller.addToken()
        XCTAssertTrue(delegate.didAddToken)
    }

    func test_whenRowsMoved_thenDelegateIsCalled() {
        moveRow(from: 0, to: 2)
        XCTAssertEqual(delegate.rearrange_input, [TokenData.gno2, TokenData.mgn, TokenData.gno, TokenData.rdn])
    }

    func test_whenHidesToken_thenDeleateIsCalled() {
        hideRow(0, 0)
        XCTAssertTrue(delegate.didHide)
    }

}

private extension ManageTokensTableViewControllerTests {

    func moveRow(from: Int, to: Int) {
        controller.tableView(
            controller.tableView, moveRowAt: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0))
    }

    func hideRow(_ row: Int, _ section: Int) {
        controller.tableView(controller.tableView, commit: .delete, forRowAt: IndexPath(row: row, section: section))
    }

}

class MockManageTokensTableViewControllerDelegate: ManageTokensTableViewControllerDelegate {

    var didAddToken = false
    func addToken() {
        didAddToken = true
    }

    var rearrange_input: [TokenData]?
    func rearrange(tokens: [TokenData]) {
        rearrange_input = tokens
    }

    var didHide = false
    func hide(token: TokenData) {
        didHide = true
    }

}
