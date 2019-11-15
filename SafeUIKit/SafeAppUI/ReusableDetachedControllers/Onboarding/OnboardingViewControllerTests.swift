//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class OnboardingViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_empty() {
        let vc = OnboardingViewController.create(steps: [])
        vc.loadViewIfNeeded()
        XCTAssertTrue(vc.viewControllers!.isEmpty)
    }

    func test_one() {
        let step = OnboardingStepInfo.testContent
        let vc = OnboardingViewController.create(steps: [step])
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.toolbar.pageControl.numberOfPages, 1)
        XCTAssertEqual(vc.toolbar.actionButtonItem.title, step.actionTitle)
    }

    func test_whenAppears_thenSetsBackButton() {
        let (nav, vc) = createEmptyControllerInNavigationStack()
        vc.viewWillAppear(false)
        XCTAssertNotNil(nav.viewControllers[0].navigationItem.backBarButtonItem)
    }

    func test_whenAppears_thenSetsEmptyNavBarShadow() {
        let (nav, vc) = createEmptyControllerInNavigationStack()
        vc.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.shadowImage?.pngData(), UIImage().pngData())
    }

    func test_whenDisappears_thenSetsNavBarShadow() {
        let (nav, vc) = createEmptyControllerInNavigationStack()
        vc.viewWillAppear(false)
        vc.viewWillDisappear(false)
        XCTAssertEqual(nav.navigationBar.shadowImage?.pngData(), Asset.image.pngData())
    }

    func test_transitionToNextPage() {
        let vc = OnboardingViewController.create(steps: [.testContent, .testContent])
        vc.loadViewIfNeeded()
        vc.transitionToNextPage()
        let secondPage = vc.pageDataSource.stepController(at: 1)
        XCTAssertEqual(vc.currentViewController, secondPage)
        XCTAssertEqual(vc.currentPageIndex, 1)
    }

    func test_whenPageControlChanged_thenTransitionsToThePag() {
        let vc = OnboardingViewController.create(steps: [.testContent, .testContent, .testContent])
        vc.loadViewIfNeeded()

        // 1 page forward
        vc.toolbar.pageControl.currentPage = 1
        vc.toolbar.pageControl.sendActions(for: .valueChanged)
        XCTAssertEqual(vc.currentPageIndex, 1)

        // 1 page reverse
        vc.toolbar.pageControl.currentPage = 0
        vc.toolbar.pageControl.sendActions(for: .valueChanged)
        XCTAssertEqual(vc.currentPageIndex, 0)

        // many pages forward
        vc.toolbar.pageControl.currentPage = 2
        vc.toolbar.pageControl.sendActions(for: .valueChanged)
        XCTAssertEqual(vc.currentPageIndex, 2)

        // page index out of bounds
        let samePage = vc.currentPageIndex
        vc.toolbar.pageControl.currentPage = 999
        vc.toolbar.pageControl.sendActions(for: .valueChanged)
        XCTAssertEqual(vc.currentPageIndex, samePage)
    }

    func test_whenTappingToolbarAction_thenInvokesControllerAction() {
        let exp = expectation(description: "Tap")

        var step = OnboardingStepInfo.testContent
        step.action = {
            exp.fulfill()
        }

        let vc = OnboardingViewController.create(steps: [step])
        vc.loadViewIfNeeded()

        vc.toolbar.actionButtonItem.sendAction()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func test_whenAnimationFinishedAfterGestureTransition_thenUpdatesToolbar() {
        var secondStep = OnboardingStepInfo.testContent
        secondStep.actionTitle = "SecondStep"
        let vc = OnboardingViewController.create(steps: [.testContent, secondStep])
        vc.loadViewIfNeeded()
        let firstVC = vc.pageDataSource.stepController(at: 0)!

        // simulate transition to the second page
        vc.setViewControllers([vc.pageDataSource.stepController(at: 1)!],
                              direction: .forward,
                              animated: false,
                              completion: nil)
        // simulate the delegate call from the UIPageViewController
        vc.pageViewController(vc,
                              didFinishAnimating: true,
                              previousViewControllers: [firstVC],
                              transitionCompleted: true)

        XCTAssertEqual(vc.toolbar.pageControl.currentPage, 1)
        XCTAssertEqual(vc.toolbar.actionButtonItem.title, secondStep.actionTitle)
    }

}

extension OnboardingViewControllerTests {

    func createEmptyControllerInNavigationStack() -> (UINavigationController, OnboardingViewController) {
        let vc = OnboardingViewController.create(steps: [])
        vc.loadViewIfNeeded()
        let nav = UINavigationController(rootViewController: UIViewController())
        nav.pushViewController(vc, animated: false)
        return (nav, vc)
    }
}
