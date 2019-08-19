//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import Common
import BigInt

class MainViewControllerTests: SafeTestCase {

    // swiftlint:disable weak_delegate
    let delegate = MockMainViewControllerDelegate()
    var vc: MainViewController!

    override func setUp() {
        super.setUp()
        walletService.assignAddress("test_address")
        vc = MainViewController.create(delegate: delegate)
    }

    func test_whenPressingMenu_thenCallsDelegate() {
        vc.openMenu(self)
        XCTAssertTrue(delegate.didCallOpenMenu)
    }

    func test_whenPressingManageTokens_thenCallsDelegate() {
        vc.manageTokens(self)
        XCTAssertTrue(delegate.didCallManageTokens)
    }

    func test_whenPressingIdenticon_thenCallsDelegate() {
        createWindow(vc)
        vc.didTapAddress(vc as Any)
        XCTAssertTrue(delegate.didOpenAddressDetails)
    }

    func test_whenPressingBanner_thenCallsDelegate() {
        createWindow(vc)
        vc.didTapBanner()
        XCTAssertTrue(delegate.didUpgradeContract)
    }

}

class MockMainViewControllerDelegate: MainViewControllerDelegate, TransactionViewViewControllerDelegate {

    func didSelectTransaction(id: String) {}

    var didCallCreateNewTransaction = false
    func createNewTransaction(token: String) {
        didCallCreateNewTransaction = true
    }

    var didCallOpenMenu = false
    func openMenu() {
        didCallOpenMenu = true
    }

    var didCallManageTokens = false
    func manageTokens() {
        didCallManageTokens = true
    }

    var didOpenAddressDetails = false
    func openAddressDetails() {
        didOpenAddressDetails = true
    }

    var didUpgradeContract = false
    func upgradeContract() {
        didUpgradeContract = true
    }

}
