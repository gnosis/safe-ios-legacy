//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public final class TokenInput: VerifiableInput {

    public private(set) var decimals: Int = 18

    private let decimalSeparator: String = (Locale.current as NSLocale).decimalSeparator

    enum Strings {
        static let amount = LocalizedString("token_input.amount", comment: "Amount placeholder for token input.")
    }

    public var imageURL: URL? {
        didSet {
            textInput.leftImageURL = imageURL
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
        textInput.placeholder = Strings.amount
        textInput.leftImage = Asset.TokenIcons.defaultToken.image
        textInput.keyboardType = .decimalPad
        textInput.delegate = self
    }

}

// MARK: - UITextFieldDelegate

public extension TokenInput {

    override func textField(_ textField: UITextField,
                            shouldChangeCharactersIn range: NSRange,
                            replacementString string: String) -> Bool {
        guard super.textField(textField, shouldChangeCharactersIn: range, replacementString: string) else {
            return false
        }
        let updatedText = (textField.nonNilText as NSString).replacingCharacters(in: range, with: string)
        let components = updatedText.components(separatedBy: decimalSeparator)
        guard components.count < 3 else { return false }
        guard components.reduce(true, { $0 && !$1.hasNonDecimalDigitCharacters }) else { return false }
        return true
    }

}
