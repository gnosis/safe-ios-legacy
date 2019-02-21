//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import AVFoundation
import CommonTestSupport

class ScannerViewControllerTests: XCTestCase {

    // swiftlint:disable:next weak_delegate
    let delegate = MockScannerDelegate()
    var controller: ScannerViewController!

    override func setUp() {
        super.setUp()
        controller = ScannerViewController.create(delegate: delegate)
    }

    func test_close_dismisses() {
        let controller = TestableScannerViewController()
        controller.close()
        XCTAssertTrue(controller.didDismiss)
    }

}

class MockScannerDelegate: ScannerDelegate {
    func didScan(_ code: String) {}
}

class TestableScannerViewController: ScannerViewController {

    var didDismiss = false

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        didDismiss = true
    }

}
