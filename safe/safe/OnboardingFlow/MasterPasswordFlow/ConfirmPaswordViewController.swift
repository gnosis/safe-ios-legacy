//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

protocol ConfirmPasswordViewControllerDelegate: class {
    func didConfirmPassword()
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

}


extension ConfirmPaswordViewController: TextInputDelegate {

    func textInputDidReturn() {
        let password = textInput.text!
        account.cleanupAllData()
        do {
            try account.setMasterPassword(password)
            account.activateBiometricAuthentication { [weak self] in
                self?.delegate?.didConfirmPassword()
            }
        } catch let e {
            // TODO: 06/03/18: handle error, show alert to user with error description
            print("Failed setMasterPassword: \(e)")
        }
    }

}
