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
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var verifiableInput: VerifiableInput!
    @IBOutlet weak var nextButton: UIBarButtonItem!

    @IBOutlet weak var bottomSpaceFromDescriptionToCardViewConstraint: NSLayoutConstraint!

    private weak var delegate: PasswordViewControllerDelegate!
    private var keyboardBehavior: KeyboardAvoidingBehavior!

    private var referencePassword: String!
    private var isSetPasswordScreen: Bool {
        return referencePassword == nil
    }

    private enum Strings {
        static let createHeader = LocalizedString("create_password", comment: "Header for set password screen.")
        static let confirmHeader = LocalizedString("confirm_password", comment: "Header for set password screen.")
        static let setupInfo = LocalizedString("setup_password_info", comment: "Set password screen description.")
        static let confirmInfo = LocalizedString("confirm_password_info", comment: "Confirmation screen description")
        static let nextButtonTitle = LocalizedString("next", comment: "Next button title")
        static let confirmButtonTitle = LocalizedString("confirm", comment: "Confirm button title")
        static let passwordPlaceholder = LocalizedString("password", comment: "Password placeholder")
    }

    static func create(delegate: PasswordViewControllerDelegate,
                       referencePassword: String? = nil) -> PasswordViewController {
        let vc = StoryboardScene.MasterPassword.passwordViewController.instantiate()
        vc.delegate = delegate
        vc.referencePassword = referencePassword
        return vc
    }

    @IBAction func proceed(_ sender: Any) {
        verifiableInput.verify()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureKeyboardBehavior()

        verifiableInput.textInput.placeholder = Strings.passwordPlaceholder

        if isSetPasswordScreen {
            headerLabel.text = Strings.createHeader
            descriptionLabel.text = Strings.setupInfo
            verifiableInput.configureForNewPassword()
            nextButton.title = Strings.nextButtonTitle
            bottomSpaceFromDescriptionToCardViewConstraint.constant = 190
        } else {
            headerLabel.text = Strings.confirmHeader
            nextButton.title = Strings.confirmButtonTitle
            descriptionLabel.text = Strings.confirmInfo
            verifiableInput.configureForConfirmPassword(referencePassword: referencePassword)
            bottomSpaceFromDescriptionToCardViewConstraint.constant = 130
        }
        verifiableInput.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isSetPasswordScreen {
            trackEvent(OnboardingEvent.setPassword)
            trackEvent(OnboardingTrackingEvent.setPassword)
        } else {
            trackEvent(OnboardingEvent.confirmPassword)
            trackEvent(OnboardingTrackingEvent.confirmPassword)
        }
    }

    private func configureKeyboardBehavior() {
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)
        keyboardBehavior.activeTextField = verifiableInput.textInput
        keyboardBehavior.useViewsSuperviewFrame = true
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
            delegate.didSetPassword(verifiableInput.text!)
        } else {
            handleConfirmPassword()
        }
    }

    private func handleConfirmPassword() {
        let password = verifiableInput.text!
        do {
            try Authenticator.instance.registerUser(password: password)
            self.delegate.didConfirmPassword()
        } catch {
            ErrorHandler.showFatalError(log: "Failed to set master password", error: error)
        }
    }

}
