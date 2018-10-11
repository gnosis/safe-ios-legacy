//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BigInt


/// Token Double Input component contains separate inputs for integer and fractional part of a Token.
/// - It validates user inputs taking into account decimal part of a Token and maximum possible value.
/// - Call setup(value:decimals:fiatConversionRate:locale) before usage.
/// - Needs BigInt as a dependency.
public class TokenDoubleInput: UIView {

    @IBOutlet weak var integerTextField: UITextField!
    @IBOutlet weak var fractionalTextField: UITextField!
    @IBOutlet weak var fiatValueLabel: UILabel!

    private let decimalSeparator: String = (Locale.current as NSLocale).decimalSeparator
    private var approximateCurrencyFormatter: ApproximateCurrencyFormatter?

    public private(set) var decimals: Int = 18
    public private(set) var value: BigInt = 0
    public private(set) var fiatConversionRate: Double?
    public private(set) var locale: Locale? {
        didSet {
            guard let locale = locale else {
                approximateCurrencyFormatter = nil
                return
            }
            approximateCurrencyFormatter = ApproximateCurrencyFormatter(locale: locale)
        }
    }

    struct Bounds {

        static let maxTokenValue = BigInt(2).power(256) - 1
        static let minTokenValue = BigInt(0)

        static let maxDigitsCount = String(maxTokenValue).count
        static let minDigitsCount = 0

        static func isWithinBounds(value: BigInt) -> Bool {
            return value >= Bounds.minTokenValue && value <= Bounds.maxTokenValue
        }

        static func hasCorrectDigitCount(_ value: Int) -> Bool {
            return value >= Bounds.minDigitsCount && value <= Bounds.maxDigitsCount
        }

    }

    enum Field: Int {
        case integer
        case fractional
    }

    /// Configut TokenInput. Call this method before component usage.
    ///
    /// - Parameters:
    ///   - value: Initital BigInt value
    ///   - decimals: Decimals of a ERC20 Token. https://theethereum.wiki/w/index.php/ERC20_Token_Standard
    ///   - fiatConversionRate: Token to fiat conversion rate.
    ///   - locale: Locale fot proper fiat currency formatting.
    public func setUp(value: BigInt, decimals: Int, fiatConversionRate: Double, locale: Locale) {
        self.fiatConversionRate = fiatConversionRate
        self.locale = locale
        setUp(value: value, decimals: decimals)
    }

    /// Configut TokenInput. Call this method before component usage.
    ///
    /// - Parameters:
    ///   - value: Initital BigInt value
    ///   - decimals: Decimals of a ERC20 Token. https://theethereum.wiki/w/index.php/ERC20_Token_Standard
    public func setUp(value: BigInt, decimals: Int) {
        precondition(Bounds.hasCorrectDigitCount(decimals))
        precondition(Bounds.isWithinBounds(value: value))
        self.decimals = decimals
        self.value = value
        updateUIOnInitialLoad()
    }

    private func updateUIOnInitialLoad() {
        let str = String(value)

        if str.count <= decimals {
            integerTextField.text = ""
            fractionalTextField.text = bigIntFractionalPartStringToUIText(str.paddingWithLeadingZeroes(to: decimals))
        } else {
            integerTextField.text = str.integerPart(decimals) + decimalSeparator
            fractionalTextField.text = bigIntFractionalPartStringToUIText(str.fractionalPart(decimals))
        }

        integerTextField.isEnabled = decimals < Bounds.maxDigitsCount
        fractionalTextField.isEnabled = decimals > Bounds.minDigitsCount

        fiatValueLabel.text = approximateFiatValue(for: value)
    }

    private func approximateFiatValue(for value: BigInt) -> String {
        guard let fiatConversionRate = fiatConversionRate,
            let approximateCurrencyFormatter = approximateCurrencyFormatter,
            let doubleValue = Double.value(from: value, decimals: decimals) else { return "" }
        let fiatValue = doubleValue * fiatConversionRate // note: _really_ big values will be "+Inf"
        return approximateCurrencyFormatter.string(from: fiatValue)
    }

    private func bigIntFractionalPartStringToUIText(_ fractionalPart: String) -> String {
        return fractionalPart.removingTrailingZeroes
    }

    private func uiTextToBigIntFractionalPartString(_ fractionalPart: String) -> String {
        return fractionalPart.paddingWithTrailingZeroes(to: decimals)
    }

    private func uiTextToBigIntIntegerPartString(_ integerPart: String) -> String {
        return integerPart.removingDecimalSeparator.removingLeadingZeroes
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    public override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        safeUIKit_loadFromNib()
        integerTextField.delegate = self
        integerTextField.tag = Field.integer.rawValue
        fractionalTextField.delegate = self
        fractionalTextField.tag = Field.fractional.rawValue
        updateUIOnInitialLoad()
    }

    /// If integer or fractional text field is first responder.
    public override var isFirstResponder: Bool {
        return integerTextField.isFirstResponder || fractionalTextField.isFirstResponder
    }

    public override func resignFirstResponder() -> Bool {
        integerTextField.resignFirstResponder()
        fractionalTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }

}

fileprivate extension String {

    var removingTrailingZeroes: String {
        var result = self
        while result.last == "0" {
            result.removeLast()
        }
        return result
    }

    var removingLeadingZeroes: String {
        var result = self
        while result.first == "0" {
            result.removeFirst()
        }
        return result
    }

    var removingDecimalSeparator: String {
        guard let decimalSeparator = Locale.current.decimalSeparator else { return self }
        return self.replacingOccurrences(of: decimalSeparator, with: "")
    }

    var hasNonDecimalDigitCharacters: Bool {
        return rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil
    }

    func paddingWithTrailingZeroes(to width: Int) -> String {
        return self + String(repeating: "0", count: width - self.count)
    }

    func paddingWithLeadingZeroes(to width: Int) -> String {
        return String(repeating: "0", count: width - self.count) + self
    }

    func integerPart(_ decimals: Int) -> String {
        return String(prefix(count - decimals))
    }

    func fractionalPart(_ decimals: Int) -> String {
        return String(suffix(decimals))
    }

}

fileprivate extension UITextField {

    var isIntegerField: Bool {
        return tag == TokenDoubleInput.Field.integer.rawValue
    }

    var isFractionalField: Bool {
        return tag == TokenDoubleInput.Field.fractional.rawValue
    }

    var nonNilText: String {
        return text ?? ""
    }
}

extension TokenDoubleInput: UITextFieldDelegate {

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn rangeToReplace: NSRange,
                          replacementString enteredString: String) -> Bool {
        let updatedText = (textField.nonNilText as NSString)
            .replacingCharacters(in: rangeToReplace, with: enteredString)

        guard updatedText.count <= Bounds.maxDigitsCount else {
            return false
        }

        if textField.isIntegerField && enteredString == decimalSeparator {
            fractionalTextField.becomeFirstResponder()
            return false
        }

        guard !enteredString.hasNonDecimalDigitCharacters else {
            return false
        }

        let isEnteringToBeginning = rangeToReplace.upperBound == 0
        if textField.isIntegerField && isEnteringToBeginning && Double(enteredString) == 0 {
            return false
        }

        if textField.isFractionalField && updatedText.count > decimals {
            return false
        }

        guard let bigIntValue = validBigIntValue(from: textField, updatedText: updatedText) else {
            return false
        }

        fiatValueLabel.text = approximateFiatValue(for: bigIntValue)

        return true
    }

    private func validBigIntValue(from currentTextField: UITextField, updatedText: String) -> BigInt? {
        let uiIntegerPart = currentTextField.isIntegerField ? updatedText : integerTextField.nonNilText
        let uiFractionalPart = currentTextField.isFractionalField ? updatedText : fractionalTextField.nonNilText
        return validBigIntValue(integerPart: uiIntegerPart, fractionalPart: uiFractionalPart)
    }

    private func validBigIntValue(integerPart: String, fractionalPart: String) -> BigInt? {
        let bigIntStringValue = uiTextToBigIntIntegerPartString(integerPart) +
                                uiTextToBigIntFractionalPartString(fractionalPart)
        guard let result = BigInt(bigIntStringValue), Bounds.isWithinBounds(value: result) else {
            return nil
        }
        return result
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard textField.isIntegerField else { return true }
        textField.text = uiTextToBigIntIntegerPartString(textField.text ?? "")
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        let bigIntValue = validBigIntValue(integerPart: integerTextField.nonNilText,
                                           fractionalPart: fractionalTextField.nonNilText)
        guard let newValue = bigIntValue else {
            value = 0
            return
        }
        value = newValue

        guard !textField.nonNilText.isEmpty else { return }

        if textField.isIntegerField {
            textField.text = uiTextToBigIntIntegerPartString(textField.nonNilText) + decimalSeparator
        } else {
            textField.text = bigIntFractionalPartStringToUIText(textField.nonNilText)
        }
    }

}
