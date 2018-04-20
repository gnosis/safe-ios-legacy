//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safeUIKit

class BarcodeInputTests: XCTestCase {

    //swiftlint:disable weak_delegate
    let delegate = MockBarcodeInputDelegate()
    let barcodeTextField = BarcodeInput()

    override func setUp() {
        super.setUp()
        barcodeTextField.barcodeDelegate = delegate
    }

    func test_init() {
        XCTAssertNotNil(barcodeTextField.rightView as? UIButton)
        XCTAssertTrue(barcodeTextField.delegate === barcodeTextField)
        XCTAssertEqual(barcodeTextField.editingMode, .scanAndType)
    }

    func test_textFieldShouldBeginEditing_whenScanAndType_thenNoDelegateCallAndReturnsTrue() {
        XCTAssertTrue(barcodeTextField.textFieldShouldBeginEditing(barcodeTextField))
        XCTAssertFalse(delegate.didPresent)
    }

    func test_textFieldShouldBeginEditing_whenScanOnly_thenCallsDelegateAndReturnsFalse() {
        barcodeTextField.editingMode = .scanOnly
        XCTAssertFalse(barcodeTextField.textFieldShouldBeginEditing(barcodeTextField))
        XCTAssertTrue(delegate.didPresent)
    }

}

class MockBarcodeInputDelegate: BarcodeInputDelegate {

    var didPresent = false

    func presentBarcodeController(_ controller: UIViewController) {
        didPresent = true
    }

}
