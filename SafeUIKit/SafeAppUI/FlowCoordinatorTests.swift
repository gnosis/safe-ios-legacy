//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class FlowCoordinatorTests: XCTestCase {

    func test_whenCreated_thenHasRootController() {
        let fc = FlowCoordinator(rootViewController: UIViewController())
        XCTAssertNotNil(fc.rootViewController)
    }

    func test_whenRootIsNavigationController_thenCanAccessIt() {
        let fc = FlowCoordinator(rootViewController: UINavigationController())
        XCTAssertTrue(fc.navigationController === fc.rootViewController)
    }

    func test_whenRootHasNavigationController_thenCanAccessNavigationController() {
        let nav = UINavigationController(rootViewController: UIViewController())
        let fc = FlowCoordinator(rootViewController: nav.topViewController!)
        XCTAssertTrue(fc.navigationController === nav)
    }

    func test_whenTransitionsToAnotherFlow_thenReusesRootController() {
        let fc = FlowCoordinator(rootViewController: UINavigationController())
        let other = FlowCoordinator()
        fc.enter(flow: other)
        XCTAssertTrue(other.rootViewController === fc.rootViewController)
    }

    func test_whenTransitionsToAnotherFlow_thenCallsSetUp() {
        class OtherFC: FlowCoordinator {

            var didSetUp = false

            override func setUp() {
                super.setUp()
                didSetUp = true
            }

        }
        let fc = FlowCoordinator(rootViewController: UINavigationController())
        let other = OtherFC()
        fc.enter(flow: other)
        XCTAssertTrue(other.didSetUp)
    }

    func test_whenExitingFlow_thenCallsCompletionFromTransition() {
        let fc = FlowCoordinator()
        let other = FlowCoordinator()
        var didFinish = false
        fc.enter(flow: other) { didFinish = true }
        other.exitFlow()
        XCTAssertTrue(didFinish)
    }

    func test_whenPushingController_thenItGoesToNavigationController() {
        let fc = FlowCoordinator(rootViewController: UINavigationController())
        let vc = UIViewController()
        fc.push(vc)
        XCTAssertTrue(fc.navigationController.topViewController === vc)
    }

    func test_whenPushingMultipleControllers_thenAllAreInStack() {
        let fc = FlowCoordinator(rootViewController: UINavigationController())
        fc.push(UIViewController())
        fc.push(UIViewController())
        delay()
        XCTAssertEqual(fc.navigationController.viewControllers.count, 2)
    }

    func test_whenPoppingController_thenRemovesFromNavigation() {
        let fc = FlowCoordinator(rootViewController: UINavigationController())
        let vc = UIViewController()
        fc.push(vc)
        fc.push(UIViewController())
        fc.pop(to: vc)
        XCTAssertTrue(fc.navigationController.topViewController === vc)
    }

    func test_whenPopping_thenPopsTopmostController() {
        let fc = FlowCoordinator(rootViewController: UINavigationController())
        let vc = UIViewController()
        fc.push(vc)
        fc.push(UIViewController())
        fc.pop()
        XCTAssertTrue(fc.navigationController.topViewController === vc)
    }


    func test_whenClearingNavigationStack_thenNoControllerPresentInNavigation() {
        let fc = FlowCoordinator(rootViewController: UINavigationController())
        fc.push(UIViewController())
        fc.push(UIViewController())
        fc.clearNavigationStack()
        XCTAssertTrue(fc.navigationController.viewControllers.isEmpty)
    }

}
