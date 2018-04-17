//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import safeUIKit

class SetPasswordViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    let delegate = MockSetPasswordViewControllerDelegate()
    var vc: SetPasswordViewController!

    override func setUp() {
        super.setUp()
        delegate.wasCalled = false
        vc = SetPasswordViewController.create(delegate: delegate)
        vc.loadViewIfNeeded()
    }

    func test_whenLoaded_thenHasAllElements() {
        XCTAssertNotNil(vc.headerLabel)
        XCTAssertNotNil(vc.textInput)
    }

    func test_whenLoaded_thenTextInputIsSecure() {
        XCTAssertTrue(vc.textInput.isSecure)
    }

    func test_whenPasswordSet_thenDelegateCalled() {
        vc.textInputDidReturn(vc.textInput)
        XCTAssertTrue(delegate.wasCalled)
    }

}

class MockSetPasswordViewControllerDelegate: SetPasswordViewControllerDelegate {

    var wasCalled = false

    func didSetPassword(_ password: String) {
        wasCalled = true
    }

}
