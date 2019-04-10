//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

protocol SetupNewPasswordViewControllerDelegate: class {
    func didEnterNewPassword(_ password: String)
}

class SetupNewPasswordViewController: UIViewController {

    private weak var delegate: SetupNewPasswordViewControllerDelegate!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var newPasswordInput: VerifiableInput!
    @IBOutlet weak var confirmNewPasswordInput: VerifiableInput!

    private let saveButton = UIBarButtonItem(title: Strings.save, style: .plain, target: self, action: #selector(save))
    private var keyboardBehavior: KeyboardAvoidingBehavior!

    private var canSave: Bool {
        return password.new == password.confirmed && newPasswordInput.isValid
    }

    // model for better communication between inputs
    struct Password {
        var new: String?
        var confirmed: String?
    }
    private var password = Password()

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
        configureKeyboardBehavior()
        _ = newPasswordInput.becomeFirstResponder()
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardBehavior?.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardBehavior?.stop()
    }

    private func configureNewPasswordInput() {
        newPasswordInput.delegate = self
        newPasswordInput.textInput.placeholder = Strings.newPasswordPlaceholder
        newPasswordInput.configureForNewPassword()
    }

    private func configureConfirmPasswordInput() {
        confirmNewPasswordInput.delegate = self
        confirmNewPasswordInput.configurePasswordAppearance()
        confirmNewPasswordInput.showErrorsOnly = true
        confirmNewPasswordInput.textInput.placeholder = Strings.confirmPasswordPlaceholder
        confirmNewPasswordInput.addRule(Strings.passwordDoesNotMatch) { $0 == self.password.new }
    }

    private func configureKeyboardBehavior() {
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)
        keyboardBehavior.activeTextField = newPasswordInput.textInput
        keyboardBehavior.useTextFieldSuperviewFrame = true
    }

    @objc func save() {
        guard canSave else { return }
        delegate.didEnterNewPassword(password.new!)
    }

    func shakeInput(_ verifiableInput: VerifiableInput) {
        verifiableInput.shake()
    }

}

extension SetupNewPasswordViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        if verifiableInput === newPasswordInput {
            if newPasswordInput.isValid {
                _ = confirmNewPasswordInput.becomeFirstResponder()
            } else {
                shakeInput(newPasswordInput)
            }
        } else {
            if confirmNewPasswordInput.isValid {
                if canSave {
                    delegate.didEnterNewPassword(password.new!)
                } else {
                    shakeInput(newPasswordInput)
                }
            } else {
                shakeInput(confirmNewPasswordInput)
            }
        }
    }

    func verifiableInputWillEnter(_ verifiableInput: VerifiableInput, newValue: String) {
        if verifiableInput === newPasswordInput {
            password.new = newValue
            confirmNewPasswordInput.revalidateText()
        } else {
            password.confirmed = newValue
        }
        saveButton.isEnabled = canSave
    }

}
