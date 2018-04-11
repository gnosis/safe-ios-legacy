//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SelectRecoveryOptionViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    private var delegate: SetupRecoveryOptionDelegate!

    override func setUp() {
        super.setUp()
        delegate = MockSetupRecoveryOptionDelegate()
    }

    func test_canCreate() {
        let controller = SelectRecoveryOptionViewController.create(delegate: delegate)
        XCTAssertNotNil(controller)
    }

}

class MockSetupRecoveryOptionDelegate: SetupRecoveryOptionDelegate {}
