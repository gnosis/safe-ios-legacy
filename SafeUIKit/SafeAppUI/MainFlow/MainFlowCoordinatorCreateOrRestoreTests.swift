//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class MainFlowCoordinatorCreateOrRestoreTests: SafeTestCase {

    var mainFlowCoordinator: MainFlowCoordinator!

    override func setUp() {
        super.setUp()
        mainFlowCoordinator = MainFlowCoordinator()
        mainFlowCoordinator.setUp()
    }

    func test_whenNoSafeSelected_thenShowsOptionsScreen() {
        walletService.expect_isSafeCreationInProgress(false)
        walletService.expect_isWalletDeployable(false)
        mainFlowCoordinator.showCreateOrRestore()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is
            OnboardingCreateOrRestoreViewController)
    }

    func test_whenDraftAlreadyExists_thenShowsNewSafeFlow() {
        walletService.expect_isSafeCreationInProgress(false)
        walletService.expect_isWalletDeployable(true)
        mainFlowCoordinator.showCreateOrRestore()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.viewControllers.last is GuidelinesViewController)
    }

    func test_didSelectNewSafe_showsNewSafeFlowStartVC() {
        mainFlowCoordinator.showCreateOrRestore()
        mainFlowCoordinator.didSelectNewSafe()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is GuidelinesViewController)
    }

    func test_whenNewSafeFlowExits_thenSetupSafeFlowExits() {
        walletService.expect_isSafeCreationInProgress(true)
        mainFlowCoordinator.showCreateOrRestore()
        delay()
        mainFlowCoordinator.newSafeFlowCoordinator.exitFlow()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is
            MainViewController)
    }

    func test_whenSelectedNewSafeFlowExits_thenSetupSafeFlowExits() {
        mainFlowCoordinator.showCreateOrRestore()
        delay()
        mainFlowCoordinator.didSelectNewSafe()
        delay()
        mainFlowCoordinator.newSafeFlowCoordinator.exitFlow()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is
            MainViewController)
    }

}
