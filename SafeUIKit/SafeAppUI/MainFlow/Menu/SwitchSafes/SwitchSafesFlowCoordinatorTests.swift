//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication

class SwitchSafesFlowCoordinatorTests: SafeTestCase {

    var switchSafesCoordinator: SwitchSafesFlowCoordinator!

    var topViewController: UIViewController? {
        return switchSafesCoordinator.navigationController.topViewController
    }

    override func setUp() {
        super.setUp()
        switchSafesCoordinator = SwitchSafesFlowCoordinator(rootViewController: UINavigationController())
        switchSafesCoordinator.setUp()
    }

    func test_startViewController_returnsSwitchSafesVC() {
        XCTAssertTrue(topViewController is SwitchSafesTableViewController)
    }

    func test_whenRequestingToRemoveWallet_thenEntersRemoveSafeFC() {
        let testFC = TestFlowCoordinator()
        let removeSafeCoordinator = RemoveSafeFlowCoordinator()
        removeSafeCoordinator.walletID = ""
        testFC.enter(flow: removeSafeCoordinator)
        let expectedViewController = testFC.topViewController
        let data = WalletData(id: "id1",
                              address: "address1",
                              name: "wallet1",
                              state: .finalizingDeployment,
                              canRemove: false,
                              isSelected: true,
                              requiresBackupToRemove: true,
                              isMultisig: false,
                              isReadOnly: false)
        switchSafesCoordinator.switchSafesTableViewController(SwitchSafesTableViewController(),
                                                              didRequestToRemove: data)
        let finalTransitionedViewController = switchSafesCoordinator.navigationController.topViewController
        XCTAssertTrue(type(of: finalTransitionedViewController) == type(of: expectedViewController))
    }

}
