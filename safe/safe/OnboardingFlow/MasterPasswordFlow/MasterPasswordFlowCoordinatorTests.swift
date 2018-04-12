//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import CommonTestSupport

class MasterPasswordFlowCoordinatorTests: XCTestCase {

    let flowCoordinator = MasterPasswordFlowCoordinator()
    var nav = UINavigationController()
    var hasSetMasterPassword = false

    override func setUp() {
        super.setUp()
        let startVC = flowCoordinator.startViewController(parent: nav)
        flowCoordinator.completion = masterPasswordFlowCompletion
        nav.pushViewController(startVC, animated: false)
    }

    private func masterPasswordFlowCompletion() {
        hasSetMasterPassword = true
    }

    func test_startViewController() {
        XCTAssertTrue(nav.topViewController is StartViewController)
    }

    func test_whenDidStart_thenSetMasterPasswordIsShown() {
        flowCoordinator.didStart()
        delay()
        XCTAssertTrue(nav.topViewController is SetPasswordViewController)
    }

    func test_whenDidSetPassword_thenConfirmPasswordIsShown() {
        flowCoordinator.didSetPassword("Any")
        delay()
        XCTAssertTrue(nav.topViewController is ConfirmPaswordViewController)
    }

    func test_whenDidConfirmPassword_thenFlowCompletionIsCalled() {
        XCTAssertFalse(hasSetMasterPassword)
        flowCoordinator.didConfirmPassword()
        XCTAssertTrue(hasSetMasterPassword)
    }

}
