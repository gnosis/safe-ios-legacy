//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BigInt

public class TokenInput: UIView {

    @IBOutlet weak var integerPartTextField: UITextField!
    @IBOutlet weak var fractionalPartTextField: UITextField!
    @IBOutlet weak var fiatValueLabel: UILabel!

    private let delimiter: Character = "."
    private var approximateCurrencyFormatter: ApproximateCurrencyFormatter?

    public private(set) var decimals: Int = 18
    public private(set) var value: BigInt = 0
    public private(set) var fiatConvertionRate: Double?
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

    public func setUp(value: BigInt, decimals: Int, fiatConvertionRate: Double? = nil, locale: Locale? = nil) {
        // maximum possible value of token is 2^256 - 1
        // String(2^256 - 1).count == 78
        precondition(decimals >= 0 && decimals <= maxDecimals)
        precondition(value >= 0 && value <= _2_pow_256_minus_1)
        precondition((fiatConvertionRate == nil && locale == nil) || (fiatConvertionRate != nil && locale != nil))
        self.decimals = decimals
        self.value = value
        self.fiatConvertionRate = fiatConvertionRate
        self.locale = locale
        updateUIOnInitialLoad()
    }

    private func updateUIOnInitialLoad() {
        let str = String(value)
        if str.count <= decimals {
            integerPartTextField.text = ""
            fractionalPartTextField.text = normalizedFractionalStringForUI(
                String(repeating: "0", count: decimals - str.count) + str)
        } else {
            integerPartTextField.text = String(str.prefix(str.count - decimals)) + String(delimiter)
            fractionalPartTextField.text = normalizedFractionalStringForUI(String(str.suffix(decimals)))
        }
        if decimals == 0 {
            fractionalPartTextField.isEnabled = false
        } else if decimals == maxDecimals {
            integerPartTextField.isEnabled = false
        }
        fiatValueLabel.text = approximateFiatValue(for: value)
    }

    private func approximateFiatValue(for value: BigInt) -> String {
        guard let fiatConvertionRate = fiatConvertionRate,
            let approximateCurrencyFormatter = approximateCurrencyFormatter,
            let doubleValue = Double.value(from: value, decimals: decimals) else { return "" }
        let fiatValue = doubleValue * fiatConvertionRate
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
        var normalizedString = initialString.replacingOccurrences(of: String(delimiter), with: "")
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
        integerPartTextField.delegate = self
        integerPartTextField.tag = Field.integer.rawValue
        fractionalPartTextField.delegate = self
        fractionalPartTextField.tag = Field.fractional.rawValue
        updateUIOnInitialLoad()
    }

    public override var isFirstResponder: Bool {
        return integerPartTextField.isFirstResponder || fractionalPartTextField.isFirstResponder
    }

    public override func resignFirstResponder() -> Bool {
        integerPartTextField.resignFirstResponder()
        fractionalPartTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }

}

extension TokenInput: UITextFieldDelegate {

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
        if textField.tag == Field.integer.rawValue && string == (Locale.current as NSLocale).decimalSeparator {
            // decimal separator pressed in integer field
            fractionalPartTextField.becomeFirstResponder()
            return false
        }
        if textField.tag == Field.integer.rawValue && range.upperBound == 0 {
            // trying to add to the beginning of integer part
            guard Double(string) != 0 else { return false }
        }
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            .replacingOccurrences(of: String(delimiter), with: "")

        var expectedFullValueString: String
        if textField.tag == Field.fractional.rawValue {
            let oldLength = textField.text?.count ?? 0
            let newLength = oldLength + string.count - range.length
            guard newLength <= decimals else {
                return false
            }
            expectedFullValueString = normalizedIntegerStringForValue(integerPartTextField.text ?? "") +
                normalizedFractionalStringForValue(updatedText)
        } else { // integer part
            let fractionalPartValue = fractionalPartTextField.text ?? ""
            expectedFullValueString = updatedText + normalizedFractionalStringForValue(fractionalPartValue)
        }

        guard let newExpectedValue = BigInt(expectedFullValueString), newExpectedValue <= _2_pow_256_minus_1 else {
            return false
        }
        fiatValueLabel.text = approximateFiatValue(for: newExpectedValue)

        return true
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = normalizedIntegerStringForValue(textField.text ?? "")
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        let expectedFullValueString = normalizedIntegerStringForValue(integerPartTextField.text ?? "") +
            normalizedFractionalStringForValue(fractionalPartTextField.text ?? "")
        guard let newValue = BigInt(expectedFullValueString), !expectedFullValueString.isEmpty else {
            value = 0
            return
        }
        value = newValue

        guard let len = textField.text?.count, len > 0 else { return }
        if textField.tag == Field.integer.rawValue {
            textField.text = normalizedIntegerStringForValue(textField.text!) + String(delimiter)
        } else {
            textField.text = normalizedFractionalStringForUI(textField.text!)
        }
    }

}
