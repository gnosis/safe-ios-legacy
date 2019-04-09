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

    private weak var delegate: PasswordViewControllerDelegate!
    private var keyboardBehavior: KeyboardAvoidingBehavior!

    private var referencePassword: String!
    private var isSetPasswordScreen: Bool {
        return referencePassword == nil
    }

    private enum Strings {
        static let createTitle = LocalizedString("onboarding.set_password.title",
                                                 comment: "Set password screen title.")
        static let confirmTitle = LocalizedString("onboarding.confirm_password.title",
                                                  comment: "Confirm password screen title.")
        static let createHeader = LocalizedString("onboarding.set_password.header",
                                                  comment: "Header for set password screen.")
        static let confirmHeader = LocalizedString("onboarding.confirm_password.header",
                                                   comment: "Header for set password screen.")
        static let description = LocalizedString("onboarding.set_password.description",
                                                 comment: "Set password screen description.")
        static let next = LocalizedString("onboarding.set_password.next",
                                          comment: "Next button title")
    }

    static func create(delegate: PasswordViewControllerDelegate,
                       referencePassword: String? = nil) -> PasswordViewController {
        let vc = StoryboardScene.MasterPassword.passwordViewController.instantiate()
        vc.delegate = delegate
        vc.referencePassword = referencePassword
        return vc
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        nextButton.title = Strings.next
    }

    @IBAction func proceed(_ sender: Any) {
        verifiableInput.verify()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureKeyboardBehavior()
        if isSetPasswordScreen {
            title = Strings.createTitle
            headerLabel.text = Strings.createHeader
            verifiableInput.configureForNewPassword()
        } else {
            title = Strings.confirmTitle
            headerLabel.text = Strings.createHeader
            verifiableInput.configureForConfirmPassword(referencePassword: referencePassword)
        }
        verifiableInput.delegate = self
        _ = verifiableInput.becomeFirstResponder()
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
        keyboardBehavior.useTextFieldSuperviewFrame = true
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
