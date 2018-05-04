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
