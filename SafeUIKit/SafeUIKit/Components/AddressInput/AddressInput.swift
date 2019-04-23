//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol AddressInputDelegate: class {
    func presentController(_ controller: UIViewController)
    func didRecieveValidAddress(_ address: String)
    func didRecieveInvalidAddress(_ string: String)
    func didClear()
}

public final class AddressInput: VerifiableInput {

    var scanHandler = ScanQRCodeHandler()
    private let addressLabel = FullEthereumAddressLabel()
    private let hexCharsSet: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                                               "a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F"]

    public weak var addressInputDelegate: AddressInputDelegate?
    private let identiconSize = CGSize(width: 26, height: 26)
    private let inputHeight: CGFloat = 56
    private let inputHeightWithAddress: CGFloat = 72
    private let addressCharacterCount: Int = 42
    private let addressDigitCount: Int = 40
    private let hexPrefix: String = "0x"
    private let textFontSize: CGFloat = 16
    private let addressLabelSidePadding: CGFloat = 12

    private var leadingInputConstraint: NSLayoutConstraint!

    public override var text: String? {
        get {
            return addressLabel.text
        }
        set {
            textInput.leftView = nil
            textInput.leftViewMode = .never
            if newValue != nil {
                let displayAddress = safeUserInput(newValue)
                addressLabel.text = displayAddress
                textInput.placeholder = nil
                validateRules(for: displayAddress)
                if isValid {
                    addressLabel.address = displayAddress
                    let identicon = IdenticonView(frame: CGRect(origin: .zero, size: identiconSize))
                    identicon.seed = displayAddress
                    textInput.leftView = identicon
                    textInput.leftViewMode = .always
                    let validAddress = addressLabel.formatter.string(from: displayAddress) ?? displayAddress
                    addressInputDelegate?.didRecieveValidAddress(validAddress)
                } else {
                    addressInputDelegate?.didRecieveInvalidAddress(displayAddress)
                }
            } else {
                addressLabel.address = nil
                textInput.placeholder = self.placeholder
                addressInputDelegate?.didClear()
            }
            leadingInputConstraint.constant = calculateLeadingInputPadding()
        }
    }

    public var placeholder: String? {
        didSet {
            let text = self.text
            self.text = text
        }
    }

    override func safeUserInput(_ text: String?) -> String {
        return super.safeUserInput(text).lowercased()
    }

    enum Strings {
        static let addressPlaceholder = LocalizedString("recipients_address",
                                                        comment: "Recipient's address in address input.")
        enum Rules {
            static let invalidAddress = LocalizedString("address_invalid",
                                                        comment: "Error to display if address is invalid.")
        }
        enum AlertActions {
            static let paste = LocalizedString("paste_from_clipboard", comment: "Paste from clipboard alert item.")
            static let scan = LocalizedString("scan_qr_code", comment: "Scan QR code alert item.")
            static let cancel = LocalizedString("cancel", comment: "Cancel alert item.")
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        scanHandler.delegate = self
        scanHandler.scanValidatedConverter = validatedAddress
        configureTextInput()
        addAddressLabel()
        showErrorsOnly = true
        trimsText = true
        text = nil
        placeholder = Strings.addressPlaceholder
        addRule(Strings.Rules.invalidAddress, identifier: "invalidAddress", validation: isValid)
        scanHandler.addDebugButtonToScannerController(title: "Test Address",
                                                      scanValue: "0x728cafe9fb8cc2218fb12a9a2d9335193caa07e0")
    }

    private func configureTextInput() {
        textInput.heightConstraint.constant = inputHeight
        textInput.style = .white
        textInput.showSuccessIndicator = false
        textInput.customRightView = dotsRightView()
        textInput.delegate = self
    }

    private func addAddressLabel() {
        configureAddressLabel()
        pinAddressLabelOnTopOfTextInput()
    }

    private func configureAddressLabel() {
        addressLabel.font = UIFont.systemFont(ofSize: textFontSize, weight: .medium)
        addressLabel.textAlignment = .left
        addressLabel.backgroundColor = .clear
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.numberOfLines = 2
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.minimumScaleFactor = 0.8
        addressLabel.lineBreakMode = .byTruncatingTail
    }

    private func dotsRightView() -> UIView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 14))
        imageView.image = Asset.AddressInput.dots.image
        imageView.contentMode = .center
        return imageView
    }

    private func pinAddressLabelOnTopOfTextInput() {
        let rightViewRect = textInput.rightViewRect(forBounds: textInput.bounds)
        let absoluteRightPadding = textInput.bounds.width - rightViewRect.maxX +
            rightViewRect.width + addressLabelSidePadding
        let absoluteLeftPadding = calculateLeadingInputPadding()
        textInput.addSubview(addressLabel)
        leadingInputConstraint = addressLabel.leadingAnchor.constraint(equalTo: textInput.leadingAnchor,
                                                                       constant: absoluteLeftPadding)
        NSLayoutConstraint.activate([
            leadingInputConstraint,
            addressLabel.trailingAnchor.constraint(equalTo: textInput.trailingAnchor, constant: -absoluteRightPadding),
            addressLabel.topAnchor.constraint(equalTo: textInput.topAnchor),
            addressLabel.bottomAnchor.constraint(equalTo: textInput.bottomAnchor)])
    }

    private func calculateLeadingInputPadding() -> CGFloat {
        let leftViewRect = textInput.leftViewRect(forBounds: textInput.bounds)
        return leftViewRect.maxX + addressLabelSidePadding
    }

    private func validatedAddress(_ address: String) -> String? {
        let safeValue = addressFromERC681(safeUserInput(address))
        return isValid(safeValue) ? safeValue : nil
    }

    private func isValid(_ address: String) -> Bool {
        let hasCorrectLengthWithPrefix = address.count == addressCharacterCount && address.hasPrefix(hexPrefix)
        let hasCorrectLengthWithoutPrefix = address.count == addressDigitCount
        guard (hasCorrectLengthWithPrefix || hasCorrectLengthWithoutPrefix) &&
            address.suffix(addressDigitCount).reduce(true, { $0 && hexCharsSet.contains($1) }) else {
            return false
        }
        return true
    }

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-681.md
    private func addressFromERC681(_ address: String) -> String {
        let withoutScheme = String(address.replacingOccurrences(of: "ethereum:", with: ""))
        let hasPrefix = withoutScheme.hasPrefix(hexPrefix)
        let withourPrefix = hasPrefix ? String(withoutScheme.dropFirst(hexPrefix.count)) : withoutScheme
        let leadingHexChars = String(withourPrefix.prefix { hexCharsSet.contains($0) })
        return hasPrefix ? hexPrefix + leadingHexChars : leadingHexChars
    }

}

// MARK: - UITextFieldDelegate

public extension AddressInput {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let alertController = UIAlertController()
        alertController.addAction(
            UIAlertAction(title: Strings.AlertActions.paste, style: .default) { _ in
                if let value = UIPasteboard.general.string {
                    self.text = value
                }
            })
        alertController.addAction(
            UIAlertAction(title: Strings.AlertActions.scan, style: .default) { _ in
                self.scanHandler.scan()

        })
        alertController.addAction(UIAlertAction(title: Strings.AlertActions.cancel, style: .cancel, handler: nil))
        addressInputDelegate?.presentController(alertController)
        return false
    }

}

extension AddressInput: ScanQRCodeHandlerDelegate {

    func presentController(_ controller: UIViewController) {
        addressInputDelegate?.presentController(controller)
    }

    func didScanCode(raw: String, converted: String?) {
        DispatchQueue.main.async {
            self.text = converted
            self.textInput.heightConstraint.constant = self.inputHeightWithAddress
        }
    }

}
