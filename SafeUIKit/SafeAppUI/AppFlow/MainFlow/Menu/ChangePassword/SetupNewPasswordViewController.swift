//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

protocol SetupNewPasswordViewControllerDelegate: class {
    func didEnterNewPassword(_ password: String)
}

final class SetupNewPasswordViewController: UIViewController {

    private weak var delegate: SetupNewPasswordViewControllerDelegate!

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var newPasswordInput: NewPasswordVerifiableInput!
    @IBOutlet weak var confirmNewPasswordInput: VerifiableInput!

    static func create(delegate: SetupNewPasswordViewControllerDelegate) -> SetupNewPasswordViewController {
        let vc = StoryboardScene.ChangePassword.setupNewPasswordViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    enum Strings {
        static let title = LocalizedString("change_password.title", comment: "Title for change password screen")
        static let save = LocalizedString("save", comment: "Save button")
        static let header = LocalizedString("new_password.header", comment: "Header for new password screen")
        static let newPasswordPlaceholder =
            LocalizedString("new_password.placeholder", comment: "Placeholder text for new password field")
        static let confirmPasswordPlaceholder =
            LocalizedString("new_password.confirm.placeholder", comment: "Placeholder text for confirm password field")
        static let passwordDoesNotMatch =
            LocalizedString("new_password.does_not_match", comment: "Confrimation password does not match error")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        headerLabel.text = Strings.header
        configureNewPasswordInput()
        configureConfirmPasswordInput()
        _ = newPasswordInput.becomeFirstResponder()
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: Strings.save, style: .plain, target: self, action: #selector(save))
    }

    private func configureNewPasswordInput() {
        newPasswordInput.delegate = self
        newPasswordInput.textInput.placeholder = Strings.newPasswordPlaceholder
    }

    private func configureConfirmPasswordInput() {
        confirmNewPasswordInput.isSecure = true
        confirmNewPasswordInput.delegate = self
        confirmNewPasswordInput.returnKeyType = .next
        confirmNewPasswordInput.showErrorsOnly = true
        confirmNewPasswordInput.textInput.placeholder = Strings.confirmPasswordPlaceholder
        confirmNewPasswordInput.addRule(Strings.passwordDoesNotMatch) { $0 == self.newPasswordInput.text }
    }

    @objc private func save() {
        // FIXME
        verifiableInputDidReturn(confirmNewPasswordInput)
    }

}

extension SetupNewPasswordViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        if verifiableInput === newPasswordInput {
            if newPasswordInput.isValid {
                _ = confirmNewPasswordInput.becomeFirstResponder()
            } else {
                newPasswordInput.shake()
            }
        } else {
            if confirmNewPasswordInput.isValid && confirmNewPasswordInput.text == newPasswordInput.text {
                if newPasswordInput.isValid {
                    delegate.didEnterNewPassword(confirmNewPasswordInput.text!)
                } else {
                    newPasswordInput.shake()
                }
            } else {
                confirmNewPasswordInput.shake()
            }
        }
    }

    func verifiableInputWillEnter(_ verifiableInput: VerifiableInput, newValue: String) {
        if verifiableInput === newPasswordInput {
            DispatchQueue.global().async {
                Timer.wait(0.1)
                DispatchQueue.main.async {
                    self.confirmNewPasswordInput.revalidateText()
                }
            }
        }
    }

}
