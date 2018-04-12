//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import CommonTestSupport

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

    func test_didSelectMnemonicRecovery_showsRecoveryWithMnemonicFlowCoordinatorStartVC() {
        flowCoordinator.didSelectMnemonicRecovery()
        delay()
        let fc = RecoveryWithMnemonicFlowCoordinator()
        let startVC = fc.startViewController(parent: flowCoordinator.rootVC)
        XCTAssertTrue(type(of: nav.topViewController!) == type(of: startVC))
    }

}
