//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication

protocol VerifyCurrentPasswordViewControllerDelegate: class {
    func didVerifyPassword()
}

final class VerifyCurrentPasswordViewController: UIViewController {

    private weak var delegate: VerifyCurrentPasswordViewControllerDelegate!

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var passwordInput: VerifiableInput!

    private var authenticationService: AuthenticationApplicationService {
        return ApplicationServiceRegistry.authenticationService
    }
    private var clockService: Clock { return ApplicationServiceRegistry.clock }

    static func create(delegate: VerifyCurrentPasswordViewControllerDelegate) -> VerifyCurrentPasswordViewController {
        let vc = StoryboardScene.ChangePassword.verifyCurrentPasswordViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    enum Strings {
        static let title = LocalizedString("change_password", comment: "Title for change password screen")
        static let next = LocalizedString("next", comment: "Next button")
        static let header = LocalizedString("enter_current_password", comment: "Enter current password")
        static let currentPasswordPlaceholder = LocalizedString("current_password", comment: "Current password")
        static let incorrect = LocalizedString("incorrect_password", comment: "Incorrect password")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        headerLabel.text = Strings.header
        passwordInput.isSecure = true
        passwordInput.delegate = self
        passwordInput.textInput.placeholder = Strings.currentPasswordPlaceholder
        passwordInput.showErrorsOnly = true

        _ = passwordInput.becomeFirstResponder()

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: Strings.next, style: .plain, target: self, action: #selector(proceed))
    }

    @objc func proceed() {
        _ = passwordInput.textFieldShouldReturn(passwordInput.textInput)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(ChangePasswordTrackingEvent.current)
    }

}

extension VerifyCurrentPasswordViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        let isValidPassword = ApplicationServiceRegistry.authenticationService.verifyPassword(verifiableInput.text!)

        if isValidPassword {
            delegate.didVerifyPassword()
        } else {
            passwordInput.setExplicitError(Strings.incorrect)
        }
    }

}
