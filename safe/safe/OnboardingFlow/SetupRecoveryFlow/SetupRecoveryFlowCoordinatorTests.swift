//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SetupRecoveryFlowCoordinatorTests: XCTestCase {

    let flowCoordinator = SetupRecoveryFlowCoordinator()
    var nav = UINavigationController()

    override func setUp() {
        super.setUp()
        let startVC = flowCoordinator.startViewController(parent: nav)
        nav.pushViewController(startVC, animated: false)
    }

    func test_startViewController() {
        XCTAssertTrue(nav.topViewController is SelectRecoveryOptionViewController)
    }

}
