//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol SetPasswordViewControllerDelegate: class {
    func didSetPassword(_ password: String)
}

final class SetPasswordViewController: UIViewController {

    @IBOutlet weak var headerLabel: H1Label!
    @IBOutlet weak var textInput: TextInput!
    private weak var delegate: SetPasswordViewControllerDelegate?

    private struct LocalizedStrings {
        static let header = NSLocalizedString("onboarding.set_password.header",
                                              comment: "Set password screen header label")
        static let length = NSLocalizedString("onboarding.set_password.length",
                                              comment: "Minimum length rule for password field")
        static let capital = NSLocalizedString("onboarding.set_password.capital",
                                               comment: "At least one capital letter rule for password field")
        static let digit = NSLocalizedString("onboarding.set_password.digit",
                                             comment: "At least one digit rule for password field")
    }

    static func create(delegate: SetPasswordViewControllerDelegate?) -> SetPasswordViewController {
        let vc = StoryboardScene.MasterPassword.setPasswordViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = LocalizedStrings.header
        textInput.delegate = self
        textInput.isSecure = true
        textInput.addRule(LocalizedStrings.length) { PasswordValidator.validateMinLength($0) }
        textInput.addRule(LocalizedStrings.capital) { PasswordValidator.validateAtLeastOneCapitalLetter($0) }
        textInput.addRule(LocalizedStrings.digit) { PasswordValidator.validateAtLeastOneDigit($0) }
        _ = textInput.becomeFirstResponder()
    }

}

extension SetPasswordViewController: TextInputDelegate {

    func textInputDidReturn(_ textInput: TextInput) {
        delegate?.didSetPassword(textInput.text!)
    }

}
