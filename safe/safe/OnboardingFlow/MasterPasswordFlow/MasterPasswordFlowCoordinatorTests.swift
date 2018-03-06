//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class MasterPasswordFlowCoordinatorTests: XCTestCase {

    let flowCoordinator = MasterPasswordFlowCoordinator()
    let account = MockAccount()
    var nav: UINavigationController!

    override func setUp() {
        super.setUp()
        flowCoordinator.account = account
        guard let nav = flowCoordinator.startViewController() as? UINavigationController else {
            XCTFail()
            return
        }
        self.nav = nav
    }

    func test_startViewController() {
        XCTAssertTrue(nav.topViewController is StartViewController)
    }

    func test_whenDidStart_thenSetMasterPasswordIsShown() {
        flowCoordinator.didStart()
        wait()
        XCTAssertTrue(nav.topViewController is SetPasswordViewController)
    }

    func test_whenDidSetPassword_thenConfirmPasswordIsShown() {
        flowCoordinator.didSetPassword("Password")
        wait()
        XCTAssertTrue(nav.topViewController is ConfirmPaswordViewController)
    }

    func test_whenDidConfirmPassword_thenPasswordSuccessIsShown() {
        flowCoordinator.didConfirmPassword("Password")
        wait()
        XCTAssertTrue(nav.topViewController is PasswordSuccessViewController)
    }

    func test_whenDidConfirmPassword_thenPasswordIsSaved() {
        flowCoordinator.didConfirmPassword("Password")
        XCTAssertTrue(account.didSavePassword)
        XCTAssertTrue(account.didCleanData)
    }

}

extension XCTestCase {

    func wait(for delay: TimeInterval = 0.1) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: delay))
    }

}
