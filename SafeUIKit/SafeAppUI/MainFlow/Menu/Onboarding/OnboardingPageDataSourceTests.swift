//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class OnboardingPageDataSourceTests: XCTestCase {

    var dataSource = OnboardingPageDataSource()
    let pageController = UIPageViewController()

    func test_empty() {
        let anyController = OnboardingStepViewController.create(content: nil)
        XCTAssertFalse(dataSource.isIndexInBounds(0))
        XCTAssertEqual(dataSource.stepCount, 0)
        XCTAssertNil(dataSource.index(of: OnboardingStepViewController.create(content: nil)))
        XCTAssertNil(dataSource.stepController(at: 0))
        XCTAssertNil(dataSource.pageViewController(pageController, viewControllerAfter: anyController))
        XCTAssertNil(dataSource.pageViewController(pageController, viewControllerAfter: anyController))
    }

    func test_one() {
        let step = OnboardingStepInfo.testContent
        dataSource.reloadData([step])

        XCTAssertTrue(dataSource.isIndexInBounds(0))
        XCTAssertFalse(dataSource.isIndexInBounds(-1))
        XCTAssertFalse(dataSource.isIndexInBounds(1))

        XCTAssertEqual(dataSource.stepCount, 1)

        XCTAssertNotNil(dataSource.stepController(at: 0))
        XCTAssertNil(dataSource.stepController(at: 1))

        let vc = dataSource.stepController(at: 0)!
        XCTAssertNil(dataSource.pageViewController(pageController, viewControllerAfter: vc))
        XCTAssertNil(dataSource.pageViewController(pageController, viewControllerBefore: vc))
    }

    func test_two() {
        dataSource.reloadData([.testContent, .testContent])

        let first = dataSource.stepController(at: 0)!
        let second = dataSource.stepController(at: 1)!

        XCTAssertNil(dataSource.pageViewController(pageController, viewControllerBefore: first))
        XCTAssertNil(dataSource.pageViewController(pageController, viewControllerAfter: second))
        XCTAssertEqual(dataSource.pageViewController(pageController, viewControllerBefore: second), first)
        XCTAssertEqual(dataSource.pageViewController(pageController, viewControllerAfter: first), second)
    }

    // many

}
