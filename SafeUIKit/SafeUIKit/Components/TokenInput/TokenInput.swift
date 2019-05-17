//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BigInt

public final class TokenInput: VerifiableInput {

    public private(set) var decimals: Int = 18
    public private(set) var value: BigInt = 0
    public private(set) var formatter = TokenFormatter()
    private let textInputHeight: CGFloat = 56

    var locale = Locale.autoupdatingCurrent

    enum Strings {
        static let amount = LocalizedString("amount", comment: "Amount placeholder for token input.")
        enum Rules {
            static let valueIsTooBig = LocalizedString("ios_token_input_value_is_too_big",
                                                       comment: "Error to display if entered value is too big.")
            static let excededAmountOfFractionalDigits =
                LocalizedString("ios_token_input_exceded_amount_of_fractional_digits",
                                comment: "Error to display if amount of fractional digits is exceded.")
            static let valueIsNotANumber =
                LocalizedString("ios_token_input_value_is_not_a_number",
                                comment: "Error to display if entered value is not a number.")
        }
    }

    public var usesEthDefaultImage: Bool = false

    public var imageURL: URL? {
        didSet {
            if usesEthDefaultImage && imageURL == nil {
                textInput.leftImage = Asset.TokenIcons.eth.image
            } else {
                textInput.leftPlaceholderImage = Asset.TokenIcons.defaultToken.image
                textInput.leftImageURL = imageURL
            }
        }
    }

    public var tokenCode: String? {
        didSet {
            guard tokenCode != nil else {
                rigthView = nil
                return
            }
            rigthView = tokenCodeView()
        }
    }

    private func tokenCodeView() -> UIView {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        label.textColor = ColorName.lightGreyBlue.color
        label.text = tokenCode! + "   \u{200c}" // padding
        label.sizeToFit()
        return label
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
        textInput.textInputHeight = textInputHeight
        textInput.style = .white
        textInput.showSuccessIndicator = false
        maxLength = TokenBounds.maxDigitsCount
        showErrorsOnly = true
        addDefaultValidationsRules()
    }

    private func addDefaultValidationsRules() {
        addRule(Strings.Rules.valueIsTooBig, identifier: "valueIsTooBig") { self.valueIsNotTooBig($0) }
        addRule(Strings.Rules.excededAmountOfFractionalDigits, identifier: "excededAmountOfFractionalDigits") {
            self.notExcededAmountOfFractionalDigits($0)
        }
        addRule(Strings.Rules.valueIsNotANumber, identifier: "valueIsNotANumber") { self.valueIsANumber($0) }
    }

    private func valueIsANumber(_ value: String) -> Bool {
        guard formatter.number(from: value, precision: decimals) != nil else { return false }
        return true
    }

    private func valueIsNotTooBig(_ value: String) -> Bool {
        guard let number = formatter.number(from: value, precision: decimals) else { return true }
        return TokenBounds.isWithinBounds(value: number.value)
    }

    private func notExcededAmountOfFractionalDigits(_ value: String) -> Bool {
        guard formatter.number(from: value, precision: decimals) != nil else { return true }
        let components = value.components(separatedBy: CharacterSet(charactersIn: TokenFormatter.decimalSeparators))
        guard components.count == 2 else { return true }
        let fractionalPart = components[1].removingTrailingZeroes
        return fractionalPart.count <= decimals
    }

    /// Configut TokenInput with initial value and decimals. Default values are value = 0, decimals = 18.
    ///
    /// - Parameters:
    ///   - value: Initital BigInt value
    ///   - decimals: Decimals of a ERC20 Token. https://theethereum.wiki/w/index.php/ERC20_Token_Standard
    public func setUp(value: BigInt, decimals: Int) {
        precondition(TokenBounds.hasCorrectDigitCount(decimals))
        precondition(TokenBounds.isWithinBounds(value: value))
        self.decimals = decimals
        self.value = value
        guard value != 0 else {
            textInput.text = nil
            return
        }
        textInput.text = stringValue()
    }

    private func stringValue() -> String {
        return formatter.localizedString(from: BigDecimal(value, decimals), locale: locale, shortFormat: false)
    }

    public override func becomeFirstResponder() -> Bool {
        return textInput.becomeFirstResponder()
    }

    public override var isFirstResponder: Bool {
        return textInput.isFirstResponder
    }

    public override func resignFirstResponder() -> Bool {
        return textInput.resignFirstResponder()
    }

}

// MARK: - UITextFieldDelegate

public extension TokenInput {

    override func textField(_ textField: UITextField,
                            shouldChangeCharactersIn range: NSRange,
                            replacementString string: String) -> Bool {
        let updatedText = (textField.nonNilText as NSString).replacingCharacters(in: range, with: string)
        return updatedText.isEmpty || formatter.number(from: updatedText, precision: decimals) != nil
    }

    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField === textInput else { return }
        guard isValid, let text = textField.text, !text.isEmpty else {
            value = 0
            return
        }
        value = formatter.number(from: text, precision: decimals)?.value ?? 0
        textInput.text = stringValue()
    }

}
