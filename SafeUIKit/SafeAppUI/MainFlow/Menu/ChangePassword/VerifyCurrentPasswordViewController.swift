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
    @IBOutlet weak var countdownStack: UIStackView!
    @IBOutlet weak var tryAgainInLabel: UILabel!
    @IBOutlet weak var countdownLabel: CountdownLabel!

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
        static let tryInText = LocalizedString("try_again_in", comment: "Try again in")
        static let currentPasswordPlaceholder = LocalizedString("current_password", comment: "Current password")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        headerLabel.text = Strings.header
        passwordInput.isSecure = true
        passwordInput.delegate = self
        passwordInput.textInput.placeholder = Strings.currentPasswordPlaceholder
        _ = passwordInput.becomeFirstResponder()
        countdownStack.isHidden = true
        countdownLabel.setup(time: authenticationService.blockedPeriodDuration,
                             clock: clockService)
        tryAgainInLabel.text = Strings.tryInText
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: Strings.next, style: .plain, target: self, action: #selector(proceed))
        startCountdownIfNeeded()
    }

    private func startCountdownIfNeeded() {
        guard authenticationService.isAuthenticationBlocked else {
            countdownStack.isHidden = true
            return
        }
        countdownStack.isHidden = false
        passwordInput.isEnabled = false
        countdownLabel.start { [weak self] in
            guard let `self` = self else { return }
            self.passwordInput.isEnabled = true
            self.countdownStack.isHidden = true
            _ = self.passwordInput.becomeFirstResponder()
        }
    }

    @objc func proceed() {
        verifiableInputDidReturn(passwordInput)
    }

}

extension VerifyCurrentPasswordViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        do {
            let result = try Authenticator.instance.authenticate(.password(verifiableInput.text!))
            if result.isSuccess {
                delegate.didVerifyPassword()
            } else {
                verifiableInput.shake()
                startCountdownIfNeeded()
            }
        } catch let e {
            ErrorHandler.showFatalError(log: "Failed to authenticate with password", error: e)
        }
    }

}
