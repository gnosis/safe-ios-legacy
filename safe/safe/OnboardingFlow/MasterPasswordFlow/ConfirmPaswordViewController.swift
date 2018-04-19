//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessApplication
import IdentityAccessImplementations

protocol ConfirmPasswordViewControllerDelegate: class {
    func didConfirmPassword()
}

final class ConfirmPaswordViewController: UIViewController {

    @IBOutlet weak var headerLabel: H1Label!
    @IBOutlet weak var textInput: TextInput!
    private var referencePassword: String!
    private weak var delegate: ConfirmPasswordViewControllerDelegate?

    private struct LocalizedString {
        static let header = NSLocalizedString("onboarding.confirm_password.header",
                                              comment: "Confirm password screen header")
        static let matchPassword = NSLocalizedString("onboarding.confirm_password.match",
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
        textInput.addRule(LocalizedString.matchPassword) { [unowned self] input in
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
