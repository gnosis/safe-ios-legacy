//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class OnboardingFlowCoordinatorTests: AbstractAppTestCase {

    var flowCoordinator = OnboardingFlowCoordinator()

    func test_startViewController_whenNoMasterPassword_thenMasterPasswordFlowStarted() {
        authenticationService.unregisterUser()
        _ = flowCoordinator.startViewController()
        let masterPasswordVC = flowCoordinator.masterPasswordFlowCoordinator.startViewController()
        XCTAssertTrue(type(of: flowCoordinator.rootVC.childViewControllers[0]) ==
                type(of: masterPasswordVC.childViewControllers[0]))
    }

    func test_startViewController_whenMasterPasswordIsSet_thenNewSafeFlowStarted() {
        try? authenticationService.registerUser(password: "password")
        _ = flowCoordinator.startViewController()
        let setupSafeVC = flowCoordinator.setupSafeFlowCoordinator.startViewController().childViewControllers[0]
        XCTAssertTrue(type(of: flowCoordinator.rootVC.childViewControllers[0]) == type(of: setupSafeVC))
    }

    func test_whenDidConfirmPassword_thenSetupSafeIsShown() {
        authenticationService.unregisterUser()
        _ = flowCoordinator.startViewController()
        flowCoordinator.masterPasswordFlowCoordinator.didConfirmPassword()
        delay()
        XCTAssertTrue(flowCoordinator.rootVC.topViewController is SetupSafeOptionsViewController)
        XCTAssertEqual(flowCoordinator.rootVC.viewControllers.count, 1)
    }

}
