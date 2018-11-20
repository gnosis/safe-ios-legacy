//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol AddressInputDelegate: class {
    func presentController(_ controller: UIViewController)
}

public final class AddressInput: VerifiableInput {

    var scanHandler = ScanQRCodeHandler()
    private let addressLabel = UILabel()
    private let hexCharsSet: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                                               "a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F"]

    public weak var addressInputDelegate: AddressInputDelegate?

    public override var text: String? {
        get {
            return addressLabel.text
        }
        set {
            if newValue != nil {
                let displayAddress = safeUserInput(newValue)
                addressLabel.text = displayAddress
                textInput.rightViewMode = .always
                textInput.placeholder = nil
                validateRules(for: addressLabel.text!)
                if isValid {
                    addressLabel.setEthereumAddress(displayAddress)
                }
            } else {
                addressLabel.text = nil
                textInput.rightViewMode = .never
                textInput.placeholder = Strings.addressPlaceholder
            }
        }
    }

    enum Strings {
        static let addressPlaceholder =
            LocalizedString("address_input.address_placeholder", comment: "Recipient's address in address input.")
        enum Rules {
            static let invalidAddress =
                LocalizedString("address_input.invalid_address", comment: "Error to display if address is invalid.")
        }
        enum AlertActions {
            static let paste = LocalizedString("address_input.alert.paste", comment: "Paste from clipboard alert item.")
            static let scan = LocalizedString("address_input.alert.scan", comment: "Scan QR code alert item.")
            static let cancel = LocalizedString("address_input.alert.cancel", comment: "Cancel alert item.")
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
        maxLength = 43 // if user scans >42 chars value, the error will be displayed.
        text = nil
        addRule(Strings.Rules.invalidAddress, identifier: "invalidAddress", validation: isValid)
        scanHandler.addDebugButtonToScannerController(title: "Test Address",
                                                      scanValue: "0x728cafe9fb8cc2218fb12a9a2d9335193caa07e0")
    }

    private func configureTextInput() {
        textInput.heightConstraint.constant = 60
        textInput.rightViewMode = .never
        textInput.leftImage = Asset.AddressInput.addressIconTmp.image
        textInput.delegate = self
    }

    private func addAddressLabel() {
        configureAddressLabel()
        pinAddressLabel()
    }

    private func configureAddressLabel() {
        addressLabel.font = UIFont.systemFont(ofSize: 18)
        addressLabel.backgroundColor = .clear
        addressLabel.numberOfLines = 2
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func pinAddressLabel() {
        let leftViewRect = textInput.leftViewRect(forBounds: textInput.bounds)
        let rightViewRect = textInput.rightViewRect(forBounds: textInput.bounds)
        let padding: CGFloat = 12
        let absoluteLeftPadding = leftViewRect.maxX + padding
        let absoluteRightPadding = textInput.bounds.width - rightViewRect.maxX + rightViewRect.width + padding
        textInput.addSubview(addressLabel)
        NSLayoutConstraint.activate([
            addressLabel.leadingAnchor.constraint(equalTo: textInput.leadingAnchor, constant: absoluteLeftPadding),
            addressLabel.trailingAnchor.constraint(equalTo: textInput.trailingAnchor, constant: -absoluteRightPadding),
            addressLabel.topAnchor.constraint(equalTo: textInput.topAnchor),
            addressLabel.bottomAnchor.constraint(equalTo: textInput.bottomAnchor)])
    }

    private func validatedAddress(_ address: String) -> String? {
        let safeValue = safeUserInput(address)
        return isValid(safeValue) ? safeValue : nil
    }

    private func isValid(_ address: String) -> Bool {
        guard ((address.count == 42 && address.hasPrefix("0x")) || (address.count == 40)) &&
            address.suffix(40).reduce(true, { $0 && hexCharsSet.contains($1) }) else {
            return false
        }
        return true
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

    override func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let shouldClear = super.textFieldShouldClear(textField)
        if shouldClear {
            text = nil
        }
        return shouldClear
    }

}

extension AddressInput: ScanQRCodeHandlerDelegate {

    func presentController(_ controller: UIViewController) {
        addressInputDelegate?.presentController(controller)
    }

    func didScanCode(raw: String, converted: String?) {
        text = raw
    }

}
