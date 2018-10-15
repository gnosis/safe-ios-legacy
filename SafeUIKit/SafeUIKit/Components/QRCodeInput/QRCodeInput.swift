//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import AVFoundation

public protocol QRCodeInputDelegate: class {
    func presentScannerController(_ controller: UIViewController)
    func presentCameraRequiredAlert(_ alert: UIAlertController)
    func didScanValidCode(_ code: String)
}

public typealias QRCodeConverter = (String) -> String?

@IBDesignable
public final class QRCodeInput: UITextField {

    typealias CameraAvailabilityCompletion = (_ available: Bool) -> Void

    private struct Strings {
        static let cameraAlertTitle = LocalizedString("scanner.camera_access_required.title",
                                                      comment: "Title for alert if camera is not accessable.")
        static let cameraAlertMessage = LocalizedString("scanner.camera_access_required.message",
                                                        comment: "Message for alert if camera is not accessable.")
        static let cameraAlertCancel = LocalizedString("cancel", comment: "Cancel button title")
        static let cameraAlertAllow = LocalizedString("scanner.camera_access_required.allow",
                                                      comment: "Button name to allow camera access")
    }

    public weak var qrCodeDelegate: QRCodeInputDelegate?
    public var qrCodeConverter: QRCodeConverter?
    public var captureDevice: AVCaptureDevice.Type = AVCaptureDevice.self

    public enum EditingMode {
        case scanOnly
        case scanAndType
    }

    public var editingMode: EditingMode = .scanAndType

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }

    private struct Constants {
        static let inputHeight: CGFloat = 34
        static let minFontSize: CGFloat = 17
    }

    private func configure() {
        heightAnchor.constraint(equalToConstant: Constants.inputHeight).isActive = true
        minimumFontSize = Constants.minFontSize
        borderStyle = .roundedRect
        let overlayButton = UIButton(type: .custom)
        overlayButton.setImage(UIImage(asset: Asset.qrCode), for: .normal)
        overlayButton.addTarget(self, action: #selector(openBarcodeSacenner), for: .touchUpInside)
        overlayButton.frame = CGRect(x: 0, y: 0, width: Constants.inputHeight, height: Constants.inputHeight)
        overlayButton.accessibilityIdentifier = "QRCodeButton"
        rightView = overlayButton
        rightViewMode = .always
        delegate = self
    }

    // TODO: refactor
    @objc private func openBarcodeSacenner() {
        checkCameraAvailability { [unowned self] success in
            DispatchQueue.main.async {
                if success {
                    self.qrCodeDelegate?.presentScannerController(self.scannerController())
                } else {
                    self.qrCodeDelegate?.presentCameraRequiredAlert(self.cameraRequiredAlert())
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
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: Strings.cameraAlertAllow, style: .cancel) { _ in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        })
        alert.addAction(UIAlertAction(title: Strings.cameraAlertCancel, style: .default))
        return alert
    }

}

extension QRCodeInput: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if editingMode == .scanOnly {
            openBarcodeSacenner()
            return false
        }
        return true
    }

    private func scannerController() -> UIViewController {
        return ScannerViewController.create(delegate: self)
    }

}

extension QRCodeInput: ScannerDelegate {

    func didScan(_ code: String) {
        if let result = qrCodeConverter?(code) {
            DispatchQueue.main.async {
                self.text = result
                self.qrCodeDelegate?.didScanValidCode(code)
            }
        }
    }

}
