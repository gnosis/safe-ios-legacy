//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common

class SwitchSafesFlowCoordinatorTests: SafeTestCase {

    var switchSafesCoordinator: SwitchSafesFlowCoordinator!
    let mainFlowCoordinator = MainFlowCoordinator()

    var topViewController: UIViewController? {
        return switchSafesCoordinator.navigationController.topViewController
    }

    override func setUp() {
        super.setUp()
        switchSafesCoordinator = SwitchSafesFlowCoordinator(rootViewController: UINavigationController())
        switchSafesCoordinator.mainFlowCoordinator = mainFlowCoordinator
        switchSafesCoordinator.setUp()
    }

    func test_startViewController_returnsSwitchSafesVC() {
        XCTAssertTrue(topViewController is SwitchSafesTableViewController)
    }

    func test_whenRequestingToRemoveWallet_thenEntersRemoveSafeFC() {
        let testFC = TestFlowCoordinator()
        let removeSafeCoordinator = RemoveSafeFlowCoordinator()
        removeSafeCoordinator.safeAddress = ""
        testFC.enter(flow: removeSafeCoordinator)
        let expectedViewController = testFC.topViewController
        let data = WalletData(id: "", address: "", name: "", state: .pending)
        switchSafesCoordinator.switchSafesTableViewController(SwitchSafesTableViewController(),
                                                              didRequestToRemove: data)
        let finalTransitionedViewController = switchSafesCoordinator.navigationController.topViewController
        XCTAssertTrue(type(of: finalTransitionedViewController) == type(of: expectedViewController))
    }

}
