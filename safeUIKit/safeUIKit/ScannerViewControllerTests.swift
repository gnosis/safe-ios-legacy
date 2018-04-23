//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safeUIKit
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

extension ScannerViewControllerTests {

    // TODO: Move to common code 
    private func createWindow(_ controller: UIViewController) {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        window.rootViewController?.present(controller, animated: false)
        delay()
        XCTAssertNotNil(controller.view.window)
    }

}

class MockScannerDelegate: ScannerDelegate {

    var scanned = false

    func didScan(_ code: String) {
        scanned = true
    }

}
