//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe

class ConfirmMnemonicViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockConfirmMnemonicDelegate()
    private var controller: ConfirmMnemonicViewController!

    override func setUp() {
        super.setUp()
        controller = ConfirmMnemonicViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.descriptionLabel)
        XCTAssertNotNil(controller.firstWordTextInput)
        XCTAssertNotNil(controller.secondWordTextInput)
        XCTAssertNotNil(controller.firstWordTextInput)
        XCTAssertNotNil(controller.secondWordTextInput)
        XCTAssertNotNil(controller.confirmButton)
        XCTAssertTrue(controller.delegate === delegate)
    }

}

final class MockConfirmMnemonicDelegate: ConfirmMnemonicDelegate {

    var confirmed = false

    func didConfirm() {
        confirmed = true
    }

}
