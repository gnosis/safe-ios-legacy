//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe

class SaveMnemonicViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockSaveMnemonicDelegate()
    private var controller: SaveMnemonicViewController!

    override func setUp() {
        super.setUp()
        controller = SaveMnemonicViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
    }

}

final class MockSaveMnemonicDelegate: SaveMnemonicDelegate {}
