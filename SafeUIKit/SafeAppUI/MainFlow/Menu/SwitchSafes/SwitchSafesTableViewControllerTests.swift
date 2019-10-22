//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication

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

    func test_whenSelectingRow_thenSelectsWallet() {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(walletService.didSelectWalletID, WalletData.pending1.id)
    }

    func test_whenRemovingRow_thenCallsDelegate() {
        controller.tableView(controller.tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(delegate.requestedToRemoveWallet, WalletData.pending1)
    }

}

class MockSwitchSafesTableViewControllerDelegate: SwitchSafesTableViewControllerDelegate {

    var selectedWallet: WalletData?
    var requestedToRemoveWallet: WalletData?

    func switchSafesTableViewController(_ controller: SwitchSafesTableViewController, didSelect wallet: WalletData) {
        selectedWallet = wallet
    }

    func switchSafesTableViewController(_ controller: SwitchSafesTableViewController,
                                        didRequestToRemove wallet: WalletData) {
        requestedToRemoveWallet = wallet
    }

    func switchSafesTableViewControllerDidFinish(_ controller: SwitchSafesTableViewController) {
        // empty
    }

}

extension WalletData {

    static let pending1 = WalletData(id: "id1",
                                     address: "address1",
                                     name: "wallet1",
                                     state: .finalizingDeployment,
                                     canRemove: false,
                                     isSelected: true,
                                     requiresBackupToRemove: true)

    static let created1 = WalletData(id: "id2",
                                     address: "address2",
                                     name: "wallet2",
                                     state: .readyToUse,
                                     canRemove: true,
                                     isSelected: false,
                                     requiresBackupToRemove: true)

}
