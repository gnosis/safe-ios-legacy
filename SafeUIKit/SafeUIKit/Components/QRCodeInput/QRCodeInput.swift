//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import AVFoundation

public protocol QRCodeInputDelegate: class {
    func presentController(_ controller: UIViewController)
    func didScanValidCode(_ code: String)
}

public typealias QRCodeConverter = (String) -> String?

public final class QRCodeInput: UITextField {

    public weak var qrCodeDelegate: QRCodeInputDelegate?
    public var scanValidatedConverter: ScanValidatedConverter? {
        didSet {
            scanHandler.scanValidatedConverter = scanValidatedConverter
        }
    }
    var scanHandler = ScanQRCodeHandler()

    public enum EditingMode {
        case scanOnly
        case scanAndType
    }

    public var editingMode: EditingMode = .scanAndType

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private struct Constants {
        static let inputHeight: CGFloat = 34
        static let minFontSize: CGFloat = 17
    }

    private func commonInit() {
        scanHandler.delegate = self
        heightAnchor.constraint(equalToConstant: Constants.inputHeight).isActive = true
        minimumFontSize = Constants.minFontSize
        borderStyle = .roundedRect
        delegate = self
        addScanButton()
    }

    private func addScanButton() {
        let overlayButton = UIButton(type: .custom)
        overlayButton.setImage(UIImage(asset: Asset.qrCode), for: .normal)
        overlayButton.addTarget(self, action: #selector(openBarcodeSacenner), for: .touchUpInside)
        overlayButton.frame = CGRect(x: 0, y: 0, width: Constants.inputHeight, height: Constants.inputHeight)
        overlayButton.accessibilityIdentifier = "QRCodeButton"
        rightView = overlayButton
        rightViewMode = .always
    }

    @objc private func openBarcodeSacenner() {
        scanHandler.scan()
    }

    public func addDebugButtonToScannerController(title: String, scanValue: String) {
        scanHandler.addDebugButtonToScannerController(title: title, scanValue: scanValue)
    }

}

extension QRCodeInput: ScanQRCodeHandlerDelegate {

    func presentController(_ controller: UIViewController) {
        qrCodeDelegate?.presentController(controller)
    }

    func didScanCode(raw: String, converted: String?) {
        DispatchQueue.main.async {
            self.text = converted
            self.qrCodeDelegate?.didScanValidCode(raw)
        }
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

}
