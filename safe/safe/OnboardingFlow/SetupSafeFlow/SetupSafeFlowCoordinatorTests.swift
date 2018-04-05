//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SetupSafeFlowCoordinatorTests: XCTestCase {

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

}
