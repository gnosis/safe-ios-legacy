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
        // TODO: 01/03/18: Localize rule
        textInput.addRule("• Passwords must match") { [unowned self] input in
            PasswordValidator.validate(input: input, equals: self.referencePassword)
        }
        _ = textInput.becomeFirstResponder()
    }

    func terminate() {
        delegate?.terminate()
    }

    private func showFatalError() {
        // TODO: 13/03/18: Localize
        let message = "Failed to set master password. The app will be closed."
        let alert = UIAlertController(title: "Fatal error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
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
