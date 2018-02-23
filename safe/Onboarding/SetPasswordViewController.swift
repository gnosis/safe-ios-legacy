//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class SetPasswordViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var minimumLengthRuleLabel: RuleLabel!
    @IBOutlet weak var capitalLetterRuleLabel: RuleLabel!
    @IBOutlet weak var digitRuleLabel: RuleLabel!

    static func create() -> SetPasswordViewController {
        return StoryboardScene.Onboarding.setPasswordViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
        passwordTextField.becomeFirstResponder()
    }

    func setMinimumLengthRuleStatus(_ status: RuleStatus) {
        minimumLengthRuleLabel.status = status
    }

    func setCapitalLetterRuleStatus(_ status: RuleStatus) {
        capitalLetterRuleLabel.status = status
    }

    func setDigitRuleStatus(_ status: RuleStatus) {
        digitRuleLabel.status = status
    }

}

extension SetPasswordViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let oldText = (textField.text ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        guard !newText.isEmpty else {
            setMinimumLengthRuleStatus(.inactive)
            setCapitalLetterRuleStatus(.inactive)
            setDigitRuleStatus(.inactive)
            return true
        }
        if newText.containsCapitalizedLetter() {
            setCapitalLetterRuleStatus(.success)
        } else {
            setCapitalLetterRuleStatus(.error)
        }
        if newText.containsDigit() {
            setDigitRuleStatus(.success)
        } else {
            setDigitRuleStatus(.error)
        }
        // TODO: const
        if newText.count >= 6 {
            setMinimumLengthRuleStatus(.success)
        } else {
            setMinimumLengthRuleStatus(.error)
        }
        return true
    }

    // TODO: textFieldShouldClear

}
