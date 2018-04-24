//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safeUIKit

class QRCodeInputTests: XCTestCase {

    //swiftlint:disable weak_delegate
    let delegate = MockQRCodeInputDelegate()
    let barcodeTextField = QRCodeInput()

    override func setUp() {
        super.setUp()
        barcodeTextField.qrCodeDelegate = delegate
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

    func test_openBarcodeSacenner_callsDelegate() {
        let button = barcodeTextField.rightView as! UIButton
        button.sendActions(for: .touchUpInside)
        XCTAssertTrue(delegate.didPresent)
    }

    func test_didScan_callsConverter() {
        var didCallConverterClosure = false
        barcodeTextField.qrCodeConverter = { input in
            didCallConverterClosure = true
            return input
        }
        barcodeTextField.didScan("test")
        XCTAssertTrue(didCallConverterClosure)
    }

    func test_didScan_whenCodeIsNotValid_thenDoesNotModifyInput() {
        barcodeTextField.text = "some input"
        barcodeTextField.qrCodeConverter = { _ in
            return nil
        }
        barcodeTextField.didScan("test")
        XCTAssertEqual(barcodeTextField.text, "some input")
        XCTAssertFalse(delegate.didScan)
    }

    func test_didScan_whenCodeIsValid_thenCallsDelegate_andFillsTextWithConvertedString() {
        barcodeTextField.qrCodeConverter = { _ in
            return "converted string"
        }
        barcodeTextField.didScan("test")
        XCTAssertEqual(barcodeTextField.text, "converted string")
        XCTAssertTrue(delegate.didScan)
    }

}

class MockQRCodeInputDelegate: QRCodeInputDelegate {

    var didPresent = false
    var didScan = false

    func presentScannerController(_ controller: UIViewController) {
        didPresent = true
    }

    func didScanValidCode() {
        didScan = true
    }

}
