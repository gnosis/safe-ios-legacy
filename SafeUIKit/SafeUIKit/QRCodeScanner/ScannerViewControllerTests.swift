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
    var controller: TestableScannerViewController!

    let multipleCodes = [
        TestableAVMetadataMachineReadableCodeObject(type: .qr, value: "first"),
        TestableAVMetadataMachineReadableCodeObject(type: .qr, value: "second")
    ]

    override func setUp() {
        super.setUp()
        controller = TestableScannerViewController.createTestable(delegate: delegate)
    }

    func test_close_dismisses() {
        let controller = TestableScannerViewController()
        controller.close()
        XCTAssertTrue(controller.didDismiss)
    }

    func test_whenRecievesMultipleQRCodesAndDelegateStops_thenDoesNotProcessRemainingCodes() {
        delegate.stopsAfterFirstScan = true
        controller.barcodesHandler(multipleCodes)
        XCTAssertEqual(delegate.receivedCodes, ["first"])
    }

    func test_whenReceivesCodesAndDelegateThrows_thenShowsError() {
        delegate.shouldThrow = true
        controller.barcodesHandler(multipleCodes)
        XCTAssertTrue(controller.test_presentedController is UIAlertController)
        XCTAssertEqual(delegate.receivedCodes, ["first"])
    }

    func test_whenStopsAndThenHandlerCalled_thenIgnoresHandling() {
        delegate.stopsAfterFirstScan = true
        controller.barcodesHandler(multipleCodes)
        controller.barcodesHandler(multipleCodes)
        XCTAssertEqual(delegate.receivedCodes, ["first"])
    }

}

class MockScannerDelegate: ScannerDelegate {

    var receivedCodes = [String]()
    var stopsAfterFirstScan = false
    var shouldThrow = false

    enum MyError: Error {
        case error
    }

    func didScan(_ code: String) throws -> Bool {
        receivedCodes.append(code)
        if shouldThrow {
            throw MyError.error
        }
        return stopsAfterFirstScan
    }

}

class TestableAVMetadataMachineReadableCodeObject: AVMetadataMachineReadableCodeObject {

    private let _type: AVMetadataObject.ObjectType
    private let _value: String?

    override var type: AVMetadataObject.ObjectType {
        return _type
    }

    override var stringValue: String? {
        return _value
    }

    init(type: AVMetadataObject.ObjectType, value: String?) {
        self._type = type
        self._value = value
    }

}

class TestableScannerViewController: ScannerViewController {

    static func createTestable(delegate: ScannerDelegate) -> TestableScannerViewController {
        let bundle = Bundle(for: ScannerViewController.self)
        let controller = TestableScannerViewController(nibName: "ScannerViewController", bundle: bundle)
        controller.delegate = delegate
        return controller
    }

    var test_presentedController: UIViewController?
    var presentedTimes = 0

    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        test_presentedController = viewControllerToPresent
        presentedTimes += 1
    }

    var didDismiss = false
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        didDismiss = true
    }

}
