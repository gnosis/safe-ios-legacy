//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

protocol SetPasswordViewControllerDelegate: class {
    func didSetPassword(_ password: String)
}

final class SetPasswordViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textInput: TextInput!
    private weak var delegate: SetPasswordViewControllerDelegate?

    struct LocalizedStrings {
        static let length = NSLocalizedString("onboarding.set_password.length",
                                              "Minimum length rule for password field")
        static let capital = NSLocalizedString("onboarding.set_password.capital",
                                               "At least one capital letter rule for password field")
        static let digit = NSLocalizedString("onboarding.set_password.digit",
                                             "At least one digit rule for password field")
    }

    static func create(delegate: SetPasswordViewControllerDelegate?) -> SetPasswordViewController {
        let vc = StoryboardScene.MasterPassword.setPasswordViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textInput.delegate = self
        textInput.addRule(LocalizedStrings.length) { PasswordValidator.validateMinLength($0) }
        textInput.addRule(LocalizedStrings.capital) { PasswordValidator.validateAtLeastOneCapitalLetter($0) }
        textInput.addRule(LocalizedStrings.digit) { PasswordValidator.validateAtLeastOneDigit($0) }
        _ = textInput.becomeFirstResponder()
    }

}

extension SetPasswordViewController: TextInputDelegate {

    func textInputDidReturn() {
        delegate?.didSetPassword(textInput.text!)
    }

}
