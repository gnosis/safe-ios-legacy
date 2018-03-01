//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class StartViewControllerTests: XCTestCase {

    let mockDelegate = MockStartViewControllerDelegate()
    var vc: StartViewController!

    override func setUp() {
        super.setUp()
        mockDelegate.wasCalled = false
        vc = StartViewController.create(delegate: mockDelegate)
        vc.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(vc.headerLabel)
    }

    func test_whenStartActionSent_thenDelegateCalled() {
        vc.start(self)
        XCTAssertTrue(mockDelegate.wasCalled)
    }

}

class MockStartViewControllerDelegate: StartViewControllerDelegate {
    var wasCalled = false

    func didStart() {
        wasCalled = true
    }
}
