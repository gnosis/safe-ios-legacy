//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import CommonTestSupport

class ScanQRCodeHandlerTests: XCTestCase {

    // swiftlint:disable:next weak_delegate
    let delegate = MockScanQRCodeHandlerDelegate()
    let captureDevice = MockAVCaptureDevice.self
    let handler = ScanQRCodeHandler()

    override func setUp() {
        super.setUp()
        handler.delegate = delegate
        handler.captureDevice = captureDevice
    }

    func test_whenCameraIsDenied_thenPresentsAlert() {
        captureDevice.authorizationStatus_result = .denied
        handler.scan()
        assertAlertPresented()
    }

    func test_whenCameraIsRestricted_thenPresentsAlert() {
        captureDevice.authorizationStatus_result = .restricted
        handler.scan()
        assertAlertPresented()
    }

    func test_whenCameraIsNotDeterminedAndConfiremed_thenRequestsAccessAndPresentsScanner() {
        captureDevice.authorizationStatus_result = .notDetermined
        handler.scan()
        XCTAssertNotNil(captureDevice.requestAccess_in_handler)
        captureDevice.requestAccess_in_handler?(true)
        assertScannerPresented()
    }

    func test_whenCameraNotDeterminedAndBlocked_thenShowsAlert() {
        captureDevice.authorizationStatus_result = .notDetermined
        handler.scan()
        XCTAssertNotNil(captureDevice.requestAccess_in_handler)
        captureDevice.requestAccess_in_handler?(false)
        assertAlertPresented()
    }

    func test_didScan_returnsInputIfNoValidatorIsSet() {
        handler.didScan("test")
        XCTAssertEqual(delegate.scannedCode, "test")
    }

    func test_didScan_callsValidatedConverter() {
        var didCallValidatedConverter = false
        handler.scanValidatedConverter = { str in
            didCallValidatedConverter = true
            return str + "_validated"
        }
        handler.didScan("test")
        XCTAssertTrue(didCallValidatedConverter)
        XCTAssertEqual(delegate.scannedCode, "test")
        XCTAssertEqual(delegate.convertedCode, "test_validated")
    }

    func test_didScan_whenCodeIsNotValid_thenDoesNotModifyInput() {
        handler.scanValidatedConverter = { _ in
            return nil
        }
        handler.didScan("test")
        XCTAssertNil(delegate.scannedCode)
    }

}

private extension ScanQRCodeHandlerTests {

    func assertAlertPresented(function: StaticString = #function, line: UInt = #line) {
        XCTAssertTrue(delegate.presentedController is UIAlertController, "Failed \(function):\(line)")
    }

    func assertScannerPresented(function: StaticString = #function, line: UInt = #line) {
        XCTAssertTrue(delegate.presentedController is ScannerViewController, "Failed \(function):\(line)")
    }

}

class MockScanQRCodeHandlerDelegate: ScanQRCodeHandlerDelegate {

    var presentedController: UIViewController?
    func presentController(_ controller: UIViewController) {
        presentedController = controller
    }

    var scannedCode: String?
    var convertedCode: String?
    func didScanCode(raw: String, converted: String?) {
        scannedCode = raw
        convertedCode = converted
    }

}
