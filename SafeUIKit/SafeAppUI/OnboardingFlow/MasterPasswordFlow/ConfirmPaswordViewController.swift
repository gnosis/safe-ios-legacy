//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication

protocol ConfirmPasswordViewControllerDelegate: class {
    func didConfirmPassword()
}

final class ConfirmPaswordViewController: UIViewController {

    @IBOutlet weak var headerLabel: H1Label!
    @IBOutlet weak var textInput: TextInput!
    private var referencePassword: String!
    private weak var delegate: ConfirmPasswordViewControllerDelegate?

    private struct Strings {
        static let header = LocalizedString("onboarding.confirm_password.header",
                                            comment: "Confirm password screen header")
        static let matchPassword = LocalizedString("onboarding.confirm_password.match",
                                                   comment: "Password confirmation must match set password rule")
    }

    static func create(referencePassword: String,
                       delegate: ConfirmPasswordViewControllerDelegate?) -> ConfirmPaswordViewController {
        let vc = StoryboardScene.MasterPassword.confirmPaswordViewController.instantiate()
        vc.referencePassword = referencePassword
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textInput.delegate = self
        textInput.isSecure = true
        textInput.addRule(Strings.matchPassword) { [unowned self] input in
            PasswordValidator.validate(input: input, equals: self.referencePassword)
        }
        _ = textInput.becomeFirstResponder()
    }

}


extension ConfirmPaswordViewController: TextInputDelegate {

    func textInputDidReturn(_ textInput: TextInput) {
        let password = textInput.text!
        do {
            try Authenticator.instance.registerUser(password: password)
            self.delegate?.didConfirmPassword()
        } catch let e {
            FatalErrorHandler.showFatalError(log: "Failed to set master password", error: e)
        }
    }

}
