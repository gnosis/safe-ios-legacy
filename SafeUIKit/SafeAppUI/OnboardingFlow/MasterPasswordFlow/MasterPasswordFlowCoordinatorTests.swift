//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class MasterPasswordFlowCoordinatorTests: XCTestCase {

    let flowCoordinator = MasterPasswordFlowCoordinator(rootViewController: UINavigationController())

    override func setUp() {
        super.setUp()
        flowCoordinator.setUp()
    }

    func test_startViewController() {
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is SetPasswordViewController)
    }

    func test_whenDidSetPassword_thenConfirmPasswordIsShown() {
        flowCoordinator.didSetPassword("Any")
        delay()
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is ConfirmPaswordViewController)
    }

    func test_whenDidConfirmPassword_thenFlowCompletionIsCalled() {
        var hasSetMasterPassword = false
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: flowCoordinator) {
            hasSetMasterPassword = true
        }
        XCTAssertFalse(hasSetMasterPassword)
        flowCoordinator.didConfirmPassword()
        XCTAssertTrue(hasSetMasterPassword)
    }

}
