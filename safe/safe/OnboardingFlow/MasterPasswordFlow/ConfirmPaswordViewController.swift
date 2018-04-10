//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessApplication
import IdentityAccessImplementations

protocol ConfirmPasswordViewControllerDelegate: class {
    func didConfirmPassword()
    func terminate()
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
        struct FatalAlert {
            static let title = NSLocalizedString("onboarding.fatal.title", comment: "Fatal error alert's title")
            static let ok = NSLocalizedString("onboarding.fatal.ok", comment: "Fatal error alert's Ok button title")
            static let message = NSLocalizedString("onboarding.fatal.message", comment: "Fatal error alert's message")
        }
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

    func terminate() {
        delegate?.terminate()
    }

    private func showFatalError() {
        let message = LocalizedString.FatalAlert.message
        let alert = UIAlertController(title: LocalizedString.FatalAlert.title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString.FatalAlert.ok, style: .default) { [weak self] _ in
            self?.terminate()
        })
        show(alert, sender: nil)
    }

}


extension ConfirmPaswordViewController: TextInputDelegate {

    func textInputDidReturn() {
        let password = textInput.text!
        do {
            try ApplicationServiceRegistry.authenticationService.registerUser(password: password) { [weak self] in
                DispatchQueue.main.async {
                    self?.delegate?.didConfirmPassword()
                }
            }
        } catch let e {
            LogService.shared.fatal("Failed to set master password", error: e)
            showFatalError()
        }
    }

}
