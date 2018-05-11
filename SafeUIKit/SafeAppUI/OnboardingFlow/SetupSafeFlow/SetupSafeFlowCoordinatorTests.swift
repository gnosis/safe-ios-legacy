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
        setupSafeFlowCoordinator = SetupSafeFlowCoordinator()
        newSafeFlowCoordinator = NewSafeFlowCoordinator()
    }

    func test_whenNoSafeSelected_thenShowsOptionsScreen() {
        let startVC = setupSafeFlowCoordinator.startViewController()
        XCTAssertTrue(startVC.childViewControllers[0] is SetupSafeOptionsViewController)
    }

    // FIXME: enable when flow coordinator's start controller can accept multiple controllers at once.
//    func test_whenSelectedDraftSafe_thenShowsNewSafeFlow() {
//        walletService.createNewDraftWallet()
//        let startVC = setupSafeFlowCoordinator.startViewController()
//        XCTAssertEqual(startVC.childViewControllers.count, 2)
//        XCTAssertTrue(startVC.childViewControllers.last is NewSafeViewController)
//    }

    func test_didSelectNewSafe_showsNewSafeFlowStartVC() {
        _ = setupSafeFlowCoordinator.startViewController()
        setupSafeFlowCoordinator.didSelectNewSafe()
        delay()
        let newSafeStartVC = newSafeFlowCoordinator.startViewController().childViewControllers[0]
        XCTAssertTrue(type(of: setupSafeFlowCoordinator.rootVC.topViewController!) == type(of: newSafeStartVC))
    }

}
