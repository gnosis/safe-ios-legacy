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
        try! authenticationService.registerUser(password: "MyPassword")
        authenticationService.allowAuthentication()
        _ = try! authenticationService.authenticateUser(.password("MyPassword"))
    }

    func test_whenNoSafeSelected_thenShowsCreateOrRestore() throws {
        walletService.expect_isSafeCreationInProgress(false)
        mainFlowCoordinator.setUp()
        delay()
        let topVC = mainFlowCoordinator.navigationController.topViewController
        XCTAssertTrue(topVC is OnboardingCreateOrRestoreViewController, String(reflecting: topVC))
    }

    func test_didSelectNewSafe_showsNewSafeFlowStartVC() {
        walletService.expect_walletState(.draft)
        mainFlowCoordinator.setUp()
        mainFlowCoordinator.didSelectNewSafe()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is OnboardingIntroViewController)
    }

    func test_whenNewSafeFlowExits_thenShowsRoot() {
        walletService.expect_walletState(.creationStarted)
        walletService.expect_isSafeCreationInProgress(true)
        mainFlowCoordinator.setUp()
        delay()
        mainFlowCoordinator.newSafeFlowCoordinator.exitFlow()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is
            OnboardingCreateOrRestoreViewController)
    }

}
