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

    func test_whenDraftAlreadyExists_thenShowsNewSafeFlow() {
        walletService.expect_isSafeCreationInProgress(false)
        walletService.expect_isWalletDeployable(true)

        let testFC = TestFlowCoordinator()
        testFC.enter(flow: setupSafeFlowCoordinator)
        delay()

        print(String(reflecting: testFC.navigationController.viewControllers.last))
        XCTAssertEqual(testFC.navigationController.viewControllers.count, 2)
        XCTAssertTrue(testFC.navigationController.viewControllers.last is NewSafeViewController)
    }

    func test_didSelectNewSafe_showsNewSafeFlowStartVC() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: setupSafeFlowCoordinator)

        setupSafeFlowCoordinator.didPressNext()
        delay()
        let newSafeStartVC = testFC.topViewController
        XCTAssertTrue(type(of: setupSafeFlowCoordinator.navigationController.topViewController) ==
            type(of: newSafeStartVC))
    }

    func test_whenNewSafeFlowExits_thenSetupSafeFlowExits() {
        walletService.expect_isSafeCreationInProgress(true)
        let testFC = TestFlowCoordinator()
        var finished = false
        testFC.enter(flow: setupSafeFlowCoordinator) {
            finished = true
        }
        setupSafeFlowCoordinator.newSafeFlowCoordinator.exitFlow()
        XCTAssertTrue(finished)
    }

    func test_whenSelectedNewSafeFlowExits_thenSetupSafeFlowExits() {
        let testFC = TestFlowCoordinator()
        var finished = false
        testFC.enter(flow: setupSafeFlowCoordinator) {
            finished = true
        }
        setupSafeFlowCoordinator.didPressNext()
        setupSafeFlowCoordinator.newSafeFlowCoordinator.exitFlow()
        XCTAssertTrue(finished)
    }

    func test_whenSelectsNewSafe_thenShowsGuidelines() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: setupSafeFlowCoordinator)

        setupSafeFlowCoordinator.didSelectNewSafe()
        delay()
        XCTAssertTrue(testFC.navigationController.topViewController is GuidelinesViewController)
    }


}
