//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe

class RecoveryWithMnemonicFlowCoordinatorTests: XCTestCase {

    let flowCoordinator = RecoveryWithMnemonicFlowCoordinator()
    var nav = UINavigationController()

    override func setUp() {
        super.setUp()
        let startVC = flowCoordinator.startViewController(parent: nav)
        nav.pushViewController(startVC, animated: false)
    }

    func test_startViewController_createsCorrectControllerWithDalegate() {
        XCTAssertTrue(nav.topViewController is SaveMnemonicViewController)
        let controller = nav.topViewController as! SaveMnemonicViewController
        XCTAssertTrue(controller.delegate === flowCoordinator)
    }

}
