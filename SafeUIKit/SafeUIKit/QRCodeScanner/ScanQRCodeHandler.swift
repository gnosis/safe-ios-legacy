//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import AVFoundation
import Common

protocol ScanQRCodeHandlerDelegate: class {
    func presentController(_ controller: UIViewController)
    func didScanCode(raw: String, converted: String?)
}

public typealias ScanValidatedConverter = (String) -> String?

class ScanQRCodeHandler {

    typealias CameraAvailabilityCompletion = (_ available: Bool) -> Void
    typealias DebugButton = (title: String, scanValue: String)

    weak var delegate: ScanQRCodeHandlerDelegate!
    var captureDevice: AVCaptureDevice.Type = AVCaptureDevice.self
    var scanValidatedConverter: ScanValidatedConverter?
    private var scannerController: ScannerViewController?
    private var debugButtons = [DebugButton]()
    private var didFinishScanning = false

    enum Strings {
        static let cameraAlertTitle = LocalizedString("scanner.camera_access_required.title",
                                                      comment: "Title for alert if camera is not accessable.")
        static let cameraAlertMessage = LocalizedString("scanner.camera_access_required.message",
                                                        comment: "Message for alert if camera is not accessable.")
        static let cameraAlertCancel = LocalizedString("cancel", comment: "Cancel button title")
        static let cameraAlertAllow = LocalizedString("scanner.camera_access_required.allow",
                                                      comment: "Button name to allow camera access")
        static let invalidCode = LocalizedString(("scanner.error.invalid_code"), comment: "Invalid code")
    }

    func scan() {
        didFinishScanning = false
        checkCameraAvailability { [unowned self] success in
            dispatch.onMainThread { self.handleCameraAvailability(success: success) }
        }
    }

    private func handleCameraAvailability(success: Bool) {
        if success {
            self.scannerController = self.createScannerController()
            self.delegate.presentController(self.scannerController!)
        } else {
            self.delegate.presentController(self.cameraRequiredAlert())
        }
    }

    private func createScannerController() -> ScannerViewController {
        let controller = ScannerViewController.create(delegate: self)
        debugButtons.forEach {
            controller.addDebugButton(title: $0.title, scanValue: $0.scanValue)
        }
        return controller
    }

    func addDebugButtonToScannerController(title: String, scanValue: String) {
        debugButtons.append((title: title, scanValue: scanValue))
    }

    private func checkCameraAvailability(_ completion: @escaping CameraAvailabilityCompletion) {
        let cameraAuthorizationStatus = captureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            askForCameraAccess(completion)
        @unknown default:
            completion(false)
        }
    }

    private func askForCameraAccess(_ completion: @escaping CameraAvailabilityCompletion) {
        captureDevice.requestAccess(for: .video, completionHandler: completion)
    }

    private func cameraRequiredAlert() -> UIAlertController {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        let alert = UIAlertController(
            title: Strings.cameraAlertTitle,
            message: Strings.cameraAlertMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.cameraAlertAllow, style: .cancel) { _ in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        })
        alert.addAction(UIAlertAction(title: Strings.cameraAlertCancel, style: .default))
        return alert
    }

}

extension ScanQRCodeHandler: ScannerDelegate {

	@discardableResult
    func didScan(_ code: String) throws -> Bool {
        if let validCode = validated(code: code) {
            notifyDidScan(raw: code, code: validCode)
            return true
        } else {
            throw NSError(domain: "io.gnosis.safe.scanQRCode",
                          code: -999,
                          userInfo: [NSLocalizedDescriptionKey: Strings.invalidCode])
        }
    }

    private func validated(code: String) -> String? {
        guard let validator = scanValidatedConverter else { return code }
        return validator(code)
    }

    private func notifyDidScan(raw: String, code: String) {
        guard let controller = scannerController else {
            delegate?.didScanCode(raw: raw, converted: code)
            return
        }
        DispatchQueue.main.async {
            controller.dismiss(animated: true) { [weak self] in
                self?.delegate?.didScanCode(raw: raw, converted: code)
            }
        }
    }

}
