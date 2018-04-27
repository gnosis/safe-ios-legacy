//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol QRCodeInputDelegate: class {
    func presentScannerController(_ controller: UIViewController)
    func didScanValidCode()
}

public typealias QRCodeConverter = (String) -> String?

@IBDesignable
public final class QRCodeInput: UITextField {

    public weak var qrCodeDelegate: QRCodeInputDelegate?
    public var qrCodeConverter: QRCodeConverter?

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
        rightView = overlayButton
        rightViewMode = .always
        delegate = self
    }

    @objc private func openBarcodeSacenner() {
        qrCodeDelegate?.presentScannerController(scannerController())
    }

}

extension QRCodeInput: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if editingMode == .scanOnly {
            qrCodeDelegate?.presentScannerController(scannerController())
            return false
        }
        return true
    }

    private func scannerController() -> UIViewController {
        return ScannerViewController.create(delegate: self)
    }

}

extension QRCodeInput: ScannerDelegate {

    // function called from background thread
    func didScan(_ code: String) {
        if let result = qrCodeConverter?(code) {
            DispatchQueue.main.async {
                self.text = result
                self.qrCodeDelegate?.didScanValidCode()
            }

        }
    }

}
