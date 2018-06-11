//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BigInt

public class TokenInput: UIView {

    @IBOutlet weak var integerPartTextField: UITextField!
    @IBOutlet weak var fractionalPartTextField: UITextField!
    @IBOutlet weak var currencyValueLabel: UILabel!

    private let delimiter: Character = "."
    public private(set) var decimals: Int = 18
    public private(set) var value: BigInt = 0

    let _2_pow_256_minus_1 = BigInt("115792089237316195423570985008687907853269984665640564039457584007913129639935")!

    enum Field: Int {
        case integer
        case fractional
    }

    public func setUp(value: BigInt, decimals: Int) {
        // maximum possible value of token is 2^256 - 1
        // String(2^256 - 1).count == 78
        precondition(decimals >= 0 && decimals <= 78)
        precondition(value >= 0 && value <= _2_pow_256_minus_1)
        self.decimals = decimals
        self.value = value
        updateUI()
    }

    private func updateUI() {
        let str = String(value)
        if str.count <= decimals {
            integerPartTextField.text = ""
            fractionalPartTextField.text = normalizedFractionalString(
                String(repeating: "0", count: decimals - str.count) + str)
        } else {
            integerPartTextField.text = String(str.prefix(str.count - decimals)) + "."
            fractionalPartTextField.text = normalizedFractionalString(String(str.suffix(decimals)))
        }
        if decimals == 0 {
            fractionalPartTextField.isEnabled = false
        }
    }

    private func normalizedFractionalString(_ initialString: String) -> String {
        var fractionalStr = initialString
        while fractionalStr.last == "0" {
            fractionalStr = String(fractionalStr.dropLast())
        }
        return fractionalStr
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
        print("Range: \(range)")
        print("Replacement string: \(string)")
        return true
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = textField.text?.replacingOccurrences(of: String(delimiter), with: "")
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if textField.tag == Field.integer.rawValue &&
            !text.isEmpty &&
            text.last != delimiter {
            textField.text! += String(delimiter)
        }
    }

}
