//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class OnboardingFlowCoordinatorTests: XCTestCase {

    func test_startViewController() {
        let fc = OnboardingFlowCoordinator()
        XCTAssertTrue(type(of: fc.startViewController()) == type(of: fc.masterPasswordFlowCoordinator.startViewController()))
    }

}
