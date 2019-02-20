//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class ScanBarButtonItemTests: XCTestCase {

    let scanBarButtonItem = ScanBarButtonItem()
    // swiftlint:disable:next weak_delegate
    let delegate = MockScanBarButtonItemDelegate()

    override func setUp() {
        super.setUp()
        scanBarButtonItem.delegate = delegate
    }

    func test_whenSettingScanValidatedConverter_thenValueForHandlerIsSet() {
        let converter: ScanValidatedConverter = { $0 }
        XCTAssertNil(scanBarButtonItem.scanHandler.scanValidatedConverter)
        scanBarButtonItem.scanValidatedConverter = converter
        XCTAssertNotNil(scanBarButtonItem.scanHandler.scanValidatedConverter)
    }

    func test_whenPresentControllerIsTriggered_thenDelegateIsCalled() {
        let controller = UIViewController()
        scanBarButtonItem.presentController(controller)
        XCTAssertEqual(controller, delegate.presentedController)
    }

    func test_whenScanCodeIsTriggered_thenDelegateIsCalled() {
        scanBarButtonItem.didScanCode(raw: "raw", converted: "converted")
        XCTAssertEqual(delegate.scannedCode, "raw")
    }

}

class MockScanBarButtonItemDelegate: ScanBarButtonItemDelegate {

    var presentedController: UIViewController?
    func scanBarButtonItemWantsToPresentController(_ controller: UIViewController) {
        presentedController = controller
    }

    var scannedCode: String?
    func scanBarButtonItemDidScanValidCode(_ code: String) {
        scannedCode = code
    }

}
