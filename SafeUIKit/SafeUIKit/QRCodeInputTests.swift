//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import CommonTestSupport
import AVFoundation

class QRCodeInputTests: XCTestCase {

    //swiftlint:disable:next weak_delegate
    let delegate = MockQRCodeInputDelegate()
    let barcodeTextField = QRCodeInput()
    let captureDevice = MockAVCaptureDevice.self

    override func setUp() {
        super.setUp()
        barcodeTextField.qrCodeDelegate = delegate
        barcodeTextField.captureDevice = captureDevice
        MockAVCaptureDevice.reset()
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
        delay()
        XCTAssertTrue(delegate.didPresent)
    }

    func test_openBarcodeSacenner_callsDelegate() {
        let button = barcodeTextField.rightView as! UIButton
        button.sendActions(for: .touchUpInside)
        delay()
        XCTAssertTrue(delegate.didPresent)
    }

    fileprivate func givenButtonWasPressed() {
        let button = barcodeTextField.rightView as! UIButton
        button.sendActions(for: .touchUpInside)
        delay()
    }

    fileprivate func assertAlertPresented() {
        givenButtonWasPressed()
        XCTAssertTrue(delegate.didAlert)
    }

    func test_whenCameraDenied_callsDelegate() {
        captureDevice.authorizationStatus_result = .denied
        assertAlertPresented()

        delegate.didAlert = false
        captureDevice.authorizationStatus_result = .restricted
        assertAlertPresented()
    }

    func test_whenCameraNotDetermined_thenRequestsAccess() {
        captureDevice.authorizationStatus_result = .notDetermined
        givenButtonWasPressed()
        XCTAssertNotNil(captureDevice.requestAccess_in_handler)
        captureDevice.requestAccess_in_handler?(true)
        delay()
        XCTAssertTrue(delegate.didPresent)
    }

    func test_whenCameraNotDeterminedAndBlocked_thenShowsAlert() {
        captureDevice.authorizationStatus_result = .notDetermined
        givenButtonWasPressed()
        XCTAssertNotNil(captureDevice.requestAccess_in_handler)
        captureDevice.requestAccess_in_handler?(false)
        delay()
        XCTAssertTrue(delegate.didAlert)
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
        delay()
        XCTAssertEqual(barcodeTextField.text, "converted string")
        XCTAssertTrue(delegate.didScan)
    }

}

class MockQRCodeInputDelegate: QRCodeInputDelegate {

    var didPresent = false
    var didScan = false
    var didAlert = false

    func presentScannerController(_ controller: UIViewController) {
        didPresent = true
    }

    func presentCameraRequiredAlert(_ alert: UIAlertController) {
        didAlert = true
    }

    func didScanValidCode() {
        didScan = true
    }

}

class MockAVCaptureDevice: AVCaptureDevice {

    class func reset() {
        authorizationStatus_result = .authorized
        authorizationStatus_in_mediaType = nil
        requestAccess_in_mediaType = nil
        requestAccess_in_handler = nil
    }

    static var authorizationStatus_result: AVAuthorizationStatus = .authorized
    static var authorizationStatus_in_mediaType: AVMediaType?
    open override class func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
        authorizationStatus_in_mediaType = mediaType
        return authorizationStatus_result
    }

    static var requestAccess_in_mediaType: AVMediaType?
    static var requestAccess_in_handler: ((Bool) -> Swift.Void)?
    open override class func requestAccess(for mediaType: AVMediaType,
                                           completionHandler handler: @escaping (Bool) -> Swift.Void) {
        requestAccess_in_mediaType = mediaType
        requestAccess_in_handler = handler
    }

}
