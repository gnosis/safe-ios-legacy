//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import CommonTestSupport

class SetupSafeFlowCoordinatorTests: SafeTestCase {

    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()
    let newSafeFlowCoordinator = NewSafeFlowCoordinator()

    func test_startViewController() {
        let startVC = setupSafeFlowCoordinator.startViewController()
        XCTAssertTrue(startVC.childViewControllers[0] is SetupSafeOptionsViewController)
    }

    func test_didSelectNewSafe_showsNewSafeFlowStartVC() {
        _ = setupSafeFlowCoordinator.startViewController()
        setupSafeFlowCoordinator.didSelectNewSafe()
        delay()
        let newSafeStartVC = newSafeFlowCoordinator.startViewController().childViewControllers[0]
        XCTAssertTrue(type(of: setupSafeFlowCoordinator.rootVC.topViewController!) == type(of: newSafeStartVC))
    }

    func test_didSelectNewSafe_shouldCreateEOA() {
        XCTAssertNil(try! identityService.getEOA())
        _ = setupSafeFlowCoordinator.startViewController()
        setupSafeFlowCoordinator.didSelectNewSafe()
        XCTAssertNotNil(try! identityService.getEOA())
    }

}
