//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe

class SelectRecoveryOptionViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockSetupRecoveryOptionDelegate()
    private var controller: SelectRecoveryOptionViewController!

    override func setUp() {
        super.setUp()
        controller = SelectRecoveryOptionViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.mnemonicRecoveryButton)
    }

    func test_setupMnemonicRecovery_whenCalled_theDelegateCalled() {
        controller.setupMnemonicRecovery(self)
        XCTAssertTrue(delegate.hasSelectedMnemonicRecovery)
    }

}

class MockSetupRecoveryOptionDelegate: SetupRecoveryOptionDelegate {

    var hasSelectedMnemonicRecovery = false

    func didSelectMnemonicRecovery() {
        hasSelectedMnemonicRecovery = true
    }

}
