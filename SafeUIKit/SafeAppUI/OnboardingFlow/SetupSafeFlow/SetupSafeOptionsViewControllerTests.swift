//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class SetupSafeOptionsViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    let delegate = MockSetupSafeOptionsDelegate()
    var vc: SetupSafeOptionsViewController!

    override func setUp() {
        super.setUp()
        vc = SetupSafeOptionsViewController.create(delegate: delegate)
        vc.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(vc.headerLabel)
        XCTAssertNotNil(vc.newSafeButton)
        XCTAssertNotNil(vc.restoreSafeButton)
    }

    func test_whenNewSafeButtonPressed_thenDelegateCalled() {
        XCTAssertFalse(delegate.pressedNewSafe)
        vc.createNewSafe(self)
        XCTAssertTrue(delegate.pressedNewSafe)
    }

}

final class MockSetupSafeOptionsDelegate: SetupSafeOptionsDelegate {

    var pressedNewSafe = false

    func didSelectNewSafe() {
        pressedNewSafe = true
    }

}
