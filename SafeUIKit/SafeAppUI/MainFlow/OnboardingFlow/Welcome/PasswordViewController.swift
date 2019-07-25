//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol PasswordViewControllerDelegate: class {
    func didSetPassword(_ password: String)
    func didConfirmPassword()
}

class PasswordViewController: UIViewController, VerifiableInputDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var verifiableInput: VerifiableInput!
    var nextButton: UIBarButtonItem!

    weak var delegate: PasswordViewControllerDelegate!
    private var keyboardBehavior: KeyboardAvoidingBehavior!

    // needed for navigation bar manipulations when this controller is removed from navigation controller
    private weak var _navigationController: UINavigationController!

    enum Strings {
        static let passwordPlaceholder = LocalizedString("password", comment: "Password placeholder")

        static let createHeader = LocalizedString("create_password", comment: "Header for set password screen.")
        static let setupInfo = LocalizedString("setup_password_info", comment: "Set password screen description.")
        static let nextButtonTitle = LocalizedString("next", comment: "Next button title")

        static let confirmHeader = LocalizedString("confirm_password", comment: "Header for set password screen.")
        static let confirmInfo = LocalizedString("confirm_password_info", comment: "Confirmation screen description")
        static let confirmButtonTitle = LocalizedString("confirm", comment: "Confirm button title")
    }

    static func create(delegate: PasswordViewControllerDelegate,
                       referencePassword: String? = nil) -> PasswordViewController {
        let nibName = String(describing: PasswordViewController.self)
        let bundle = Bundle(for: PasswordViewController.self)
        var result: PasswordViewController = SetPasswordViewController(nibName: nibName, bundle: bundle)
        if let referencePassword = referencePassword {
            result = ConfirmPasswordViewController(nibName: nibName, bundle: bundle)
            (result as! ConfirmPasswordViewController).referencePassword = referencePassword
        }
        result.delegate = delegate
        return result
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureKeyboardBehavior()
        nextButton = UIBarButtonItem(title: Strings.nextButtonTitle,
                                     style: .done,
                                     target: self,
                                     action: #selector(proceed(_:)))
        navigationItem.rightBarButtonItem = nextButton
        verifiableInput.textInput.placeholder = Strings.passwordPlaceholder
        verifiableInput.delegate = self
    }

    @objc func proceed(_ sender: Any) {
        verifiableInput.verify()
    }

    private func configureKeyboardBehavior() {
        verifiableInput.avoidKeyboard()
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)
        keyboardBehavior.activeTextField = verifiableInput.textInput
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardBehavior.start()
        _navigationController = navigationController
        _navigationController?.navigationBar.setBackgroundImage(Asset.navbarFilled.image, for: .default)
        _navigationController?.navigationBar.shadowImage = UIImage()
        _navigationController?.navigationBar.tintColor = .white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardBehavior.stop()
        _navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        _navigationController?.navigationBar.shadowImage = Asset.shadow.image
        _navigationController?.navigationBar.tintColor = ColorName.hold.color
    }

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        // overriden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

fileprivate final class SetPasswordViewController: PasswordViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = Strings.createHeader
        descriptionLabel.text = Strings.setupInfo
        verifiableInput.configureForNewPassword()
        nextButton.title = Strings.nextButtonTitle
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingEvent.setPassword)
        trackEvent(OnboardingTrackingEvent.setPassword)
    }

    override func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        delegate.didSetPassword(verifiableInput.text!)
    }

}

fileprivate final class ConfirmPasswordViewController: PasswordViewController {

    var referencePassword: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = Strings.confirmHeader
        nextButton.title = Strings.confirmButtonTitle
        descriptionLabel.text = Strings.confirmInfo
        verifiableInput.configureForConfirmPassword(referencePassword: referencePassword)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingEvent.confirmPassword)
        trackEvent(OnboardingTrackingEvent.confirmPassword)
    }

    override func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        let password = verifiableInput.text!
        DispatchQueue.global.async {
            do {
                try Authenticator.instance.registerUser(password: password)
                DispatchQueue.main.async {
                    self.delegate.didConfirmPassword()
                }
            } catch {
                DispatchQueue.main.async {
                    ErrorHandler.showFatalError(log: "Failed to set master password", error: error)
                }
            }
        }
    }

}
