//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class MasterPasswordFlowCoordinatorTests: XCTestCase {

    func test_startViewController() {
        let fc = MasterPasswordFlowCoordinator()
        guard let nav = fc.startViewController() as? UINavigationController else {
            XCTFail()
            return
        }
        XCTAssertTrue(nav.topViewController is StartViewController)
    }

}
