//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe

class PairWithBrowserExtensionViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    let delegate = MockPairWithBrowserDelegate()
    var controller: PairWithBrowserExtensionViewController!

    override func setUp() {
        super.setUp()
        controller = PairWithBrowserExtensionViewController.create(delegate: delegate)
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertTrue(controller.delegate === delegate)
    }

}

class MockPairWithBrowserDelegate: PairWithBrowserDelegate {

    func didPair(_ extensionAddress: String) {}

}
