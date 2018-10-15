//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import AVFoundation

protocol ScanQRCodeHandlerDelegate: class {
    func presentController(_ controller: UIViewController)
    func didScanCode(_ code: String)
}

class ScanQRCodeHandler {

    typealias CameraAvailabilityCompletion = (_ available: Bool) -> Void
    typealias ScanValidator = (String) -> String?

    weak var delegate: ScanQRCodeHandlerDelegate!
    private var captureDevice: AVCaptureDevice.Type = AVCaptureDevice.self
    private var scanValidator: ScanValidator?
    private var scannerController: UIViewController?

    enum Strings {
        static let cameraAlertTitle = LocalizedString("scanner.camera_access_required.title",
                                                      comment: "Title for alert if camera is not accessable.")
        static let cameraAlertMessage = LocalizedString("scanner.camera_access_required.message",
                                                        comment: "Message for alert if camera is not accessable.")
        static let cameraAlertCancel = LocalizedString("cancel", comment: "Cancel button title")
        static let cameraAlertAllow = LocalizedString("scanner.camera_access_required.allow",
                                                      comment: "Button name to allow camera access")
    }

    init(delegate: ScanQRCodeHandlerDelegate, scanValidator: ScanValidator? = nil) {
        self.delegate = delegate
        self.scanValidator = scanValidator
    }

    func scan() {
        checkCameraAvailability { [unowned self] success in
            DispatchQueue.main.async {
                if success {
                    self.scannerController = ScannerViewController.create(delegate: self)
                    self.delegate.presentController(self.scannerController!)
                } else {
                    self.delegate.presentController(self.cameraRequiredAlert())
                }
            }
        }
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

    func didScan(_ code: String) {
        if let scanValidator = scanValidator {
            if let result = scanValidator(code) {
                didScanValidatedCode(result)
            }
        } else {
            didScanValidatedCode(code)
        }
    }

    private func didScanValidatedCode(_ code: String) {
        delegate.didScanCode(code)
        scannerController?.dismiss(animated: true)
    }

}
