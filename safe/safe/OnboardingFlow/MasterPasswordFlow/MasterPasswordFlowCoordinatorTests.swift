//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class MasterPasswordFlowCoordinatorTests: XCTestCase {

    let fc = MasterPasswordFlowCoordinator()
    var nav: UINavigationController!

    override func setUp() {
        super.setUp()
        guard let nav = fc.startViewController() as? UINavigationController else {
            XCTFail()
            return
        }
        self.nav = nav
    }

    func test_startViewController() {
        XCTAssertTrue(nav.topViewController is StartViewController)
    }

    func test_whenDidStart_thenSetMasterPasswordIsShown() {
        fc.didStart()
        wait()
        XCTAssertTrue(nav.topViewController is SetPasswordViewController)
    }

    func test_whenDidSetPassword_thenConfirmPasswordIsShown() {
        fc.didSetPassword("Password")
        wait()
        XCTAssertTrue(nav.topViewController is ConfirmPaswordViewController)
    }

}

extension XCTestCase {

    func wait(for delay: TimeInterval = 0.1) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: delay))
    }

}
