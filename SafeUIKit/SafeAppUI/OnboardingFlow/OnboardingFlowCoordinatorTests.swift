//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class OnboardingFlowCoordinatorTests: SafeTestCase {

    var flowCoordinator: OnboardingFlowCoordinator!

    override func setUp() {
        super.setUp()
        flowCoordinator = OnboardingFlowCoordinator(rootViewController: UINavigationController())
    }

    func test_whenUserNotRegistered_thenShowsStartScreen() {
        authenticationService.unregisterUser()
        flowCoordinator.setUp()
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is StartViewController)
    }


    func test_startViewController_whenNoMasterPassword_thenMasterPasswordFlowStarted() {
        let testFC = TestFlowCoordinator()
        let masterPasswordFC = MasterPasswordFlowCoordinator()
        testFC.enter(flow: masterPasswordFC)
        let expectedController = testFC.topViewController

        authenticationService.unregisterUser()
        flowCoordinator.setUp()
        flowCoordinator.didStart()

        XCTAssertNotNil(flowCoordinator.navigationController.topViewController)
        XCTAssertTrue(type(of: flowCoordinator.navigationController.topViewController) == type(of: expectedController))
    }

    func test_startViewController_whenMasterPasswordIsSet_thenNewSafeFlowStarted() {
        let testFC = TestFlowCoordinator()
        let setupSafeFC = SetupSafeFlowCoordinator()
        testFC.enter(flow: setupSafeFC)
        let expectedController = testFC.topViewController

        try? authenticationService.registerUser(password: "password")
        flowCoordinator.setUp()

        XCTAssertNotNil(flowCoordinator.navigationController.topViewController)
        XCTAssertTrue(type(of: flowCoordinator.navigationController.topViewController) == type(of: expectedController))
    }

    func test_whenDidConfirmPassword_thenSetupSafeIsShown() {
        authenticationService.unregisterUser()
        flowCoordinator.setUp()
        flowCoordinator.didStart()
        delay(0.25)
        flowCoordinator.masterPasswordFlowCoordinator.didConfirmPassword()
        delay(0.25)
        let controller = flowCoordinator.navigationController.topViewController
        print(String(reflecting: controller.self))
        XCTAssertTrue(controller is SetupSafeOptionsViewController)
    }

}
