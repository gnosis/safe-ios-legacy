//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class OnboardingFlowCoordinatorTests: XCTestCase {

    func test_startViewController() {
        let fc = OnboardingFlowCoordinator()
        let startVC = fc.startViewController()
        let masterVC = fc.masterPasswordFlowCoordinator.startViewController()
        XCTAssertTrue(type(of: startVC) == type(of: masterVC))
    }

}
