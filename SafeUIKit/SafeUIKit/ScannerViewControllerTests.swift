//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import AVFoundation
import CommonTestSupport

class ScannerViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    let delegate = MockScannerDelegate()
    var controller: ScannerViewController!

    override func setUp() {
        super.setUp()
        controller = ScannerViewController.create(delegate: delegate)
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
    }

    func test_close_dismisses() {
        createWindow(controller)
        controller.close(self)
        delay(1)
        XCTAssertNil(controller.view.window)
    }

}

class MockScannerDelegate: ScannerDelegate {
    func didScan(_ code: String) {}
}
