//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol PasswordViewControllerDelegate: class {
    func didSetPassword(_ password: String)
    func didConfirmPassword()
}

final class PasswordViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var verifiableInput: VerifiableInput!

    private weak var delegate: PasswordViewControllerDelegate?
    private var keyboardBehavior: KeyboardAvoidingBehavior!

    private var referencePassword: String!
    private var isSetPasswordScreen: Bool {
        return referencePassword == nil
    }

    private enum Strings {
        static let title = LocalizedString("onboarding.set_password.title",
                                           comment: "Set password screen title.")
        static let confirmTitle = LocalizedString("onboarding.confirm_password.title",
                                                  comment: "Confirm password screen title.")
        static let description = LocalizedString("onboarding.set_password.description",
                                                 comment: "Set password screen description.")
        static let length = LocalizedString("onboarding.set_password.length",
                                            comment: "Use a minimum of 8 characters.")
        static let letterAndDigit = LocalizedString("onboarding.set_password.letter_and_digit",
                                                    comment: "At least 1 digit and 1 letter.")
        static let trippleChars = LocalizedString("onboarding.set_password.no_tripple_chars",
                                                  comment: "No triple characters.")
        static let matchPassword = LocalizedString("onboarding.confirm_password.match",
                                                   comment: "Passwords must match.")
    }

    static func create(delegate: PasswordViewControllerDelegate?,
                       referencePassword: String? = nil) -> PasswordViewController {
        let vc = StoryboardScene.MasterPassword.passwordViewController.instantiate()
        vc.delegate = delegate
        vc.referencePassword = referencePassword
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if isSetPasswordScreen {
            title = Strings.title
            addSetPasswordRules()
        } else {
            title = Strings.confirmTitle
            addConfirmPasswordRules()
        }
        configureKeyboardBehavior()
        configureInput()
    }

    private func configureInput() {
        verifiableInput.delegate = self
        verifiableInput.isSecure = true
        verifiableInput.style = .dimmed
        _ = verifiableInput.becomeFirstResponder()
    }

    private func configureKeyboardBehavior() {
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)
        keyboardBehavior.activeTextField = verifiableInput.textInput
        keyboardBehavior.useTextFieldSuperviewFrame = true
    }

    private func addSetPasswordRules() {
        verifiableInput.addRule(Strings.length) {
            PasswordValidator.validateMinLength($0)
        }
        verifiableInput.addRule(Strings.letterAndDigit) {
            PasswordValidator.validateAtLeastOneLetterAndOneDigit($0)
        }
        verifiableInput.addRule(Strings.trippleChars) {
            PasswordValidator.validateNoTrippleChar($0)
        }
    }

    private func addConfirmPasswordRules() {
        verifiableInput.addRule(Strings.matchPassword) { [unowned self] input in
            PasswordValidator.validate(input: input, equals: self.referencePassword)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardBehavior.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardBehavior.stop()
    }

}

extension PasswordViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        if isSetPasswordScreen {
            delegate?.didSetPassword(verifiableInput.text!)
        } else {
            handleConfirmPassword()
        }
    }

    private func handleConfirmPassword() {
        let password = verifiableInput.text!
        do {
            try Authenticator.instance.registerUser(password: password)
            self.delegate?.didConfirmPassword()
        } catch let e {
            ErrorHandler.showFatalError(log: "Failed to set master password", error: e)
        }
    }

}
