//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class ScanButtonTests: XCTestCase {

    let scanButton = ScanButton()
    // swiftlint:disable:next weak_delegate
    let delegate = MockScanButtonDelegate()

    override func setUp() {
        super.setUp()
        scanButton.delegate = delegate
    }

    func test_whenSettingScanValidatedConverter_thenValueForHandlerIsSet() {
        let converter: ScanValidatedConverter = { $0 }
        XCTAssertNil(scanButton.scanHandler.scanValidatedConverter)
        scanButton.scanValidatedConverter = converter
        XCTAssertNotNil(scanButton.scanHandler.scanValidatedConverter)
    }

    func test_whenPresentControllerIsTriggered_thenDelegateIsCalled() {
        let controller = UIViewController()
        scanButton.presentController(controller)
        XCTAssertEqual(controller, delegate.presentedController)
    }

    func test_whenScanCodeIsTriggered_thenDelegateIsCalled() {
        scanButton.didScanCode(raw: "raw", converted: "converted")
        XCTAssertEqual(delegate.scannedCode, "raw")
    }

}

class MockScanButtonDelegate: ScanButtonDelegate {

    var presentedController: UIViewController?
    func presentController(_ controller: UIViewController) {
        presentedController = controller
    }

    var scannedCode: String?
    func didScanValidCode(_ button: ScanButton, code: String) {
        scannedCode = code
    }

}
