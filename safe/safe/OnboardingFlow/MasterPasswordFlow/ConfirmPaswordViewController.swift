//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

protocol ConfirmPasswordViewControllerDelegate: class {
    func didConfirmPassword(_ password: String)
}

final class ConfirmPaswordViewController: UIViewController {

    @IBOutlet weak var textInput: TextInput!
    private var referencePassword: String!
    private weak var delegate: ConfirmPasswordViewControllerDelegate?

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
        // TODO: 01/03/18: Localize rule
        textInput.addRule("• Passwords must match") { [unowned self] input in
            PasswordValidator.validate(input: input, equals: self.referencePassword)
        }
        _ = textInput.becomeFirstResponder()
    }

}


extension ConfirmPaswordViewController: TextInputDelegate {

    func textInputDidReturn() {
        delegate?.didConfirmPassword(textInput.text!)
    }

}
