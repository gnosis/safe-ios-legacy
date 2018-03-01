//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class ConfirmPaswordViewControllerTests: XCTestCase {

    let vc = ConfirmPaswordViewController.create(referencePassword: "a")

    override func setUp() {
        super.setUp()
        vc.loadViewIfNeeded()
    }

    func test_whenCreated_hasAllElements() {
        XCTAssertNotNil(vc.textInput)
    }

}
