//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SetupSafeFlowCoordinatorTests: XCTestCase {

    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    func test_startViewController() {
        XCTAssertTrue(setupSafeFlowCoordinator.startViewController().childViewControllers[0] is SetupSafeViewController)
    }

}
