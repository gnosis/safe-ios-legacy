//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class UnlockViewControllerTests: XCTestCase {

    func test_whenCreated_hasAllElements() {
        let vc = UnlockViewController.create()
        vc.loadViewIfNeeded()
        XCTAssertNotNil(vc.textInput)
        XCTAssertNotNil(vc.loginWithBiometryButton)
        XCTAssertNotNil(vc.headerLabel)
    }

}
