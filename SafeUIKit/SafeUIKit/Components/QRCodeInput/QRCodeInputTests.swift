//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import CommonTestSupport
import AVFoundation

class QRCodeInputTests: XCTestCase {

    // swiftlint:disable:next weak_delegate
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
        XCTAssertNil(delegate.presentedController)
    }

    func test_textFieldShouldBeginEditing_whenScanOnly_thenCallsDelegateAndReturnsFalse() {
        barcodeTextField.editingMode = .scanOnly
        XCTAssertFalse(barcodeTextField.textFieldShouldBeginEditing(barcodeTextField))
        delay(1)
        assertScannerPresented()
    }

    func test_openBarcodeSacenner_callsDelegate() {
        let button = barcodeTextField.rightView as! UIButton
        button.sendActions(for: .touchUpInside)
        delay(1)
        assertScannerPresented()
    }

    func test_didScan_whenCodeIsNotValid_thenDoesNotModifyInput() {
        barcodeTextField.text = "some input"
        barcodeTextField.scanValidatedConverter = { _ in
            return nil
        }
        barcodeTextField.scanHandler.didScan("test")
        delay()
        XCTAssertEqual(barcodeTextField.text, "some input")
        XCTAssertNil(delegate.scannedCode)
    }

    func test_didScan_whenCodeIsValid_thenCallsDelegate_andFillsTextWithConvertedString() {
        barcodeTextField.scanValidatedConverter = { _ in
            return "converted string"
        }
        barcodeTextField.scanHandler.didScan("test")
        delay()
        XCTAssertEqual(barcodeTextField.text, "converted string")
        XCTAssertEqual(delegate.scannedCode, "test")
    }

    private func givenButtonWasPressed() {
        let button = barcodeTextField.rightView as! UIButton
        button.sendActions(for: .touchUpInside)
        delay()
    }

    private func assertAlertPresented() {
        givenButtonWasPressed()
        XCTAssertTrue(delegate.presentedController is UIAlertController)
    }

    private func assertScannerPresented() {
        givenButtonWasPressed()
        XCTAssertTrue(delegate.presentedController is ScannerViewController)
    }

}

class MockQRCodeInputDelegate: QRCodeInputDelegate {

    var presentedController: UIViewController?
    func presentController(_ controller: UIViewController) {
        presentedController = controller
    }

    var scannedCode: String?
    func didScanValidCode(_ code: String) {
        scannedCode = code
    }

}
