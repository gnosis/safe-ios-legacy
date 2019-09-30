//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common

class SwitchSafesTableViewControllerTests: SafeTestCase {

    let controller = SwitchSafesTableViewController()
    // swiftlint:disable:next weak_delegate
    let delegate = MockSwitchSafesTableViewControllerDelegate()

    override func setUp() {
        super.setUp()
        walletService.walletsOutput = [WalletData.pending1, WalletData.created1]
        controller.delegate = delegate
        controller.viewWillAppear(false)
    }

    func test_tracking() {
        controller.viewDidAppear(false)
        XCTAssertTracksAppearance(in: controller, SafesTrackingEvent.switchSafes)
    }

    func test_whenSelectingRow_thenCallsDelegate() {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(delegate.selectedWallet, WalletData.pending1)
    }

    func test_whenRemovingRow_thenCallsDelegate() {
        controller.tableView(controller.tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(delegate.requestedToRemoveWallet, WalletData.pending1)
    }

}

class MockSwitchSafesTableViewControllerDelegate: SwitchSafesTableViewControllerDelegate {

    var selectedWallet: WalletData?
    func didSelect(wallet: WalletData) {
        selectedWallet = wallet
    }

    var requestedToRemoveWallet: WalletData?
    func didRequestToRemove(wallet: WalletData) {
        requestedToRemoveWallet = wallet
    }

}

extension WalletData {

    static let pending1 = WalletData(address: "p1", name: "p1", state: .pendingCreation)
    static let created1 = WalletData(address: "c1", name: "c1", state: .created)

}
