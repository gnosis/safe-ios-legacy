//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

protocol ConfirmPasswordViewControllerDelegate: class {
    func didConfirmPassword()
    func terminate()
}

final class ConfirmPaswordViewController: UIViewController {

    @IBOutlet weak var textInput: TextInput!
    private var referencePassword: String!
    private weak var delegate: ConfirmPasswordViewControllerDelegate?
    private var account: AccountProtocol!

    struct LocalizedString {
        static let matchPassword = NSLocalizedString("onboarding.confirm_password.match",
                                                     "Password confirmation must match set password rule")
        struct FatalAlert {
            static let title = NSLocalizedString("onboarding.fatal.title", "Fatal error alert's title")
            static let ok = NSLocalizedString("onboarding.fatal.ok", "Fatal error alert's Ok button title")
            static let message = NSLocalizedString("onboarding.fatal.message", "Fatal error alert's message")
        }
    }

    static func create(account: AccountProtocol,
                       referencePassword: String,
                       delegate: ConfirmPasswordViewControllerDelegate?) -> ConfirmPaswordViewController {
        let vc = StoryboardScene.MasterPassword.confirmPaswordViewController.instantiate()
        vc.referencePassword = referencePassword
        vc.delegate = delegate
        vc.account = account
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textInput.delegate = self
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
            try account.cleanupAllData()
            try account.setMasterPassword(password)
            account.activateBiometricAuthentication { [weak self] in
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
