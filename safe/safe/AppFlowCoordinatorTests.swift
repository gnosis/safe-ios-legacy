//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AppFlowCoordinatorTests: XCTestCase {

    func test_startViewController() {
        let fc = AppFlowCoordinator()
        let root = fc.startViewController()
        XCTAssertTrue(type(of: root) == type(of: fc.onboardingFlowCoordinator.startViewController()))
    }

}
