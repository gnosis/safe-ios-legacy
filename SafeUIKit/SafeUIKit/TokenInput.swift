//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BigInt


/// Token Input component contains separate inputs for integer and fractional part of a Token.
/// - It validates user inputs taking into account decimal part of a Token and maximum possible value.
/// - Call setup(value:decimals:fiatConversionRate:locale) before usage.
/// - Needs BigInt as a dependency.
public class TokenInput: UIView {

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

    let _2_pow_256_minus_1 = BigInt("115792089237316195423570985008687907853269984665640564039457584007913129639935")!
    let maxDecimals = 78

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
        // maximum possible value of token is 2^256 - 1
        // String(2^256 - 1).count == 78
        precondition(decimals >= 0 && decimals <= maxDecimals)
        precondition(value >= 0 && value <= _2_pow_256_minus_1)
        self.decimals = decimals
        self.value = value
        updateUIOnInitialLoad()
    }

    private func updateUIOnInitialLoad() {
        let str = String(value)
        if str.count <= decimals {
            integerTextField.text = ""
            fractionalTextField.text = normalizedFractionalStringForUI(
                String(repeating: "0", count: decimals - str.count) + str)
        } else {
            integerTextField.text = String(str.prefix(str.count - decimals)) + decimalSeparator
            fractionalTextField.text = normalizedFractionalStringForUI(String(str.suffix(decimals)))
        }

        integerTextField.isEnabled = true
        fractionalTextField.isEnabled = true
        if decimals == 0 {
            fractionalTextField.isEnabled = false
        } else if decimals == maxDecimals {
            integerTextField.isEnabled = false
        }
        fiatValueLabel.text = approximateFiatValue(for: value)
    }

    private func approximateFiatValue(for value: BigInt) -> String {
        guard let fiatConversionRate = fiatConversionRate,
            let approximateCurrencyFormatter = approximateCurrencyFormatter,
            let doubleValue = Double.value(from: value, decimals: decimals) else { return "" }
        let fiatValue = doubleValue * fiatConversionRate
        return approximateCurrencyFormatter.string(from: fiatValue)
    }

    private func normalizedFractionalStringForUI(_ initialString: String) -> String {
        var fractionalStr = initialString
        while fractionalStr.last == "0" {
            fractionalStr.removeLast()
        }
        return fractionalStr
    }

    private func normalizedFractionalStringForValue(_ initialString: String) -> String {
        return initialString + String(repeating: "0", count: decimals - initialString.count)
    }

    private func normalizedIntegerStringForValue(_ initialString: String) -> String {
        var normalizedString = initialString.replacingOccurrences(of: decimalSeparator, with: "")
        while normalizedString.first == "0" {
            normalizedString.removeFirst()
        }
        return normalizedString
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

extension TokenInput: UITextFieldDelegate {

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {

        // decimal separator pressed in integer field
        if textField.tag == Field.integer.rawValue && string == decimalSeparator {
            fractionalTextField.becomeFirstResponder()
            return false
        }

        // trying to add to the beginning of integer part
        if textField.tag == Field.integer.rawValue && range.upperBound == 0 {
            guard Double(string) != 0 else { return false }
        }

        // allow only digits
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }

        // calculate resulting value string
        guard let expectedFullValueString =
            expectedValueString(textField: textField, range: range, replacementString: string) else {
                return false
        }

        // validate on maximum allowed value
        guard let newExpectedValue = BigInt(expectedFullValueString),
            newExpectedValue >= 0 && newExpectedValue <= _2_pow_256_minus_1 else {
            return false
        }

        // update fiat value label
        fiatValueLabel.text = approximateFiatValue(for: newExpectedValue)

        return true
    }

    private func expectedValueString(textField: UITextField, range: NSRange, replacementString: String) -> String? {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return nil }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: replacementString)
            .replacingOccurrences(of: decimalSeparator, with: "")

        var value: String
        if textField.tag == Field.fractional.rawValue { // fractional part
            guard updatedText.count <= decimals else { return nil }
            value = normalizedIntegerStringForValue(integerTextField.text ?? "") +
                normalizedFractionalStringForValue(updatedText)
        } else { // integer part
            let fractionalPartValue = fractionalTextField.text ?? ""
            value = updatedText + normalizedFractionalStringForValue(fractionalPartValue)
        }
        return value
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = normalizedIntegerStringForValue(textField.text ?? "")
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        let expectedFullValueString = normalizedIntegerStringForValue(integerTextField.text ?? "") +
            normalizedFractionalStringForValue(fractionalTextField.text ?? "")
        guard let newValue = BigInt(expectedFullValueString), !expectedFullValueString.isEmpty else {
            value = 0
            return
        }
        value = newValue

        guard let len = textField.text?.count, len > 0 else { return }
        if textField.tag == Field.integer.rawValue {
            textField.text = normalizedIntegerStringForValue(textField.text!) + decimalSeparator
        } else {
            textField.text = normalizedFractionalStringForUI(textField.text!)
        }
    }

}
