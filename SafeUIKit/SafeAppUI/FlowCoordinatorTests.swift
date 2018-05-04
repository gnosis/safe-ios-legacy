//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class FlowCoordinatorTests: XCTestCase {

    private let flowCoordinator = MockFlowCoordinator()

    func test_flowStartController_whenCalled_rootViewControllerAlreadySet() {
        _ = flowCoordinator.startViewController()
        XCTAssertTrue(flowCoordinator.rootViewControllerIsSet)
        XCTAssertTrue(flowCoordinator.rootVC is TransparentNavigationController)
        XCTAssertTrue(flowCoordinator.rootVC.childViewControllers[0] is TestVC)
    }

    func test_startViewController_setsRootIfParentPassed() {
        let parent = UINavigationController()
        _ = flowCoordinator.startViewController(parent: parent)
        XCTAssertEqual(parent, flowCoordinator.rootVC)
    }

}

private class TestVC: UIViewController {}

private class MockFlowCoordinator: FlowCoordinator {

    var rootViewControllerIsSet = false

    override func flowStartController() -> UIViewController {
        if rootVC != nil { rootViewControllerIsSet = true }
        return TestVC()
    }

}
