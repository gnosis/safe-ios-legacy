//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class SetupSafeFlowCoordinatorTests: SafeTestCase {

    var setupSafeFlowCoordinator: SetupSafeFlowCoordinator!
    var newSafeFlowCoordinator: NewSafeFlowCoordinator!

    override func setUp() {
        super.setUp()
        setupSafeFlowCoordinator = SetupSafeFlowCoordinator(rootViewController: UINavigationController())
        newSafeFlowCoordinator = NewSafeFlowCoordinator()
        setupSafeFlowCoordinator.setUp()
    }

    func test_whenNoSafeSelected_thenShowsOptionsScreen() {
        XCTAssertTrue(setupSafeFlowCoordinator.navigationController.topViewController is SetupSafeOptionsViewController)
    }

    // FIXME: enable when flow coordinator's start controller can accept multiple controllers at once.
//    func test_whenSelectedDraftSafe_thenShowsNewSafeFlow() {
//        walletService.createNewDraftWallet()
//        let startVC = setupSafeFlowCoordinator.startViewController()
//        XCTAssertEqual(startVC.childViewControllers.count, 2)
//        XCTAssertTrue(startVC.childViewControllers.last is NewSafeViewController)
//    }

    func test_didSelectNewSafe_showsNewSafeFlowStartVC() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: newSafeFlowCoordinator)

        setupSafeFlowCoordinator.didSelectNewSafe()
        delay()
        let newSafeStartVC = testFC.topViewController
        XCTAssertTrue(type(of: setupSafeFlowCoordinator.navigationController.topViewController) ==
            type(of: newSafeStartVC))
    }

}
