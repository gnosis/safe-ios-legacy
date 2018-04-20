//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol BarcodeInputDelegate: class {
    func presentBarcodeController(_ controller: UIViewController)
}

@IBDesignable
public final class BarcodeInput: UITextField {

    public weak var barcodeDelegate: BarcodeInputDelegate?

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
        barcodeDelegate?.presentBarcodeController(barcodeScannerController())
    }

}

extension BarcodeInput: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if editingMode == .scanOnly {
            barcodeDelegate?.presentBarcodeController(barcodeScannerController())
            return false
        }
        return true
    }

    private func barcodeScannerController() -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .red
        return controller
    }

}
