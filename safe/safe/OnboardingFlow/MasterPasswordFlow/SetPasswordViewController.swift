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

    static func create(delegate: SetPasswordViewControllerDelegate?) -> SetPasswordViewController {
        let vc = StoryboardScene.MasterPassword.setPasswordViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textInput.delegate = self
        // TODO: 28/02/2018 Localize
        textInput.addRule("• Minimum 6 charachters") { PasswordValidator.validateMinLength($0) }
        textInput.addRule("• Should have a capital letter") { PasswordValidator.validateAtLeastOneCapitalLetter($0) }
        textInput.addRule("• Should have a digit") { PasswordValidator.validateAtLeastOneDigit($0) }
        _ = textInput.becomeFirstResponder()
    }

}

extension SetPasswordViewController: TextInputDelegate {

    func textInputDidReturn() {
        delegate?.didSetPassword(textInput.text!)
    }

}
