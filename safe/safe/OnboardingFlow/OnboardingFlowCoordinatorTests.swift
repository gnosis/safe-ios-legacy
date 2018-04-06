//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class OnboardingFlowCoordinatorTests: AbstractAppTestCase {

    var flowCoordinator = OnboardingFlowCoordinator()

    func test_startViewController_whenNoMasterPassword_thenMasterPasswordFlowStarted() {
        account.hasMasterPassword = false
        _ = flowCoordinator.startViewController()
        let masterPasswordVC = flowCoordinator.masterPasswordFlowCoordinator.startViewController()
        XCTAssertTrue(type(of: flowCoordinator.rootVC.childViewControllers[0]) ==
                type(of: masterPasswordVC.childViewControllers[0]))
    }

    func test_startViewController_whenMasterPasswordIsSet_thenNewSafeFlowStarted() {
        account.hasMasterPassword = true
        _ = flowCoordinator.startViewController()
        let setupSafeVC = flowCoordinator.setupSafeFlowCoordinator.startViewController().childViewControllers[0]
        XCTAssertTrue(type(of: flowCoordinator.rootVC.childViewControllers[0]) == type(of: setupSafeVC))
    }

    func test_whenDidConfirmPassword_thenSetupSafeIsShown() {
        account.hasMasterPassword = false
        _ = flowCoordinator.startViewController()
        flowCoordinator.masterPasswordFlowCoordinator.didConfirmPassword()
        delay()
        XCTAssertTrue(flowCoordinator.rootVC.topViewController is SetupSafeOptionsViewController)
        XCTAssertEqual(flowCoordinator.rootVC.viewControllers.count, 1)
    }

}
