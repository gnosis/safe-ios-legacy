//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import AVFoundation

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
    }

    func scan() {
        didFinishScanning = false
        checkCameraAvailability { [unowned self] success in
            DispatchQueue.main.async {
                if success {
                    self.scannerController = self.createScannerController()
                    self.delegate.presentController(self.scannerController!)
                } else {
                    self.delegate.presentController(self.cameraRequiredAlert())
                }
            }
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
        if let scanValidatedConverter = scanValidatedConverter {
            if let result = scanValidatedConverter(code) {
                didScanCode(raw: code, converted: result)
            }
        } else {
            didScanCode(raw: code)
        }
    }

    private func didScanCode(raw: String, converted: String? = nil) {
        guard !didFinishScanning else { return }
        didFinishScanning = true
        if let controller = scannerController {
            controller.dismiss(animated: true) { [weak self] in
                self?.delegate.didScanCode(raw: raw, converted: converted)
            }
        } else {
            delegate.didScanCode(raw: raw, converted: converted)
        }
    }

}
