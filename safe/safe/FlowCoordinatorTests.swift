//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class FlowCoordinatorTests: XCTestCase {

    let flowCoordinator = MockFlowCoordinator()

    func test_flowStartController_whenCalled_rootViewControllerAlreadySet() {
        _ = flowCoordinator.startViewController()
        XCTAssertTrue(flowCoordinator.rootViewControllerIsSet)
        XCTAssertTrue(flowCoordinator.rootVC is TransparentNavigationController)
    }

    func test_startViewController_setsRootIfParentPassed() {
        let parent = UINavigationController()
        _ = flowCoordinator.startViewController(parent: parent)
        XCTAssertEqual(parent, flowCoordinator.rootVC)
    }

}

class MockFlowCoordinator: FlowCoordinator {
    
    var rootViewControllerIsSet = false

    override func flowStartController() -> UIViewController {
        if rootVC != nil { rootViewControllerIsSet = true }
        return UIViewController()
    }

}
