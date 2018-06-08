//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TokenInput: UIView {

    @IBOutlet weak var integerPartTextField: UITextField!
    @IBOutlet weak var fractionalPartTextField: UITextField!
    @IBOutlet weak var currencyValueLabel: UILabel!

    private let delimiter: Character = "."

    enum Field: Int {
        case integer
        case fractional
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
