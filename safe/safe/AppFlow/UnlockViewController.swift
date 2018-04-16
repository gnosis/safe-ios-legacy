//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessApplication
import IdentityAccessDomainModel

final class UnlockViewController: UIViewController {

    @IBOutlet weak var countdownLabel: CountdownLabel!
    @IBOutlet weak var headerLabel: H1Label!
    @IBOutlet weak var textInput: TextInput!
    @IBOutlet weak var loginWithBiometryButton: UIButton!
    private var unlockCompletion: (() -> Void)!
    private var clockService: Clock { return ApplicationServiceRegistry.clock }
    private var authenticationService: AuthenticationApplicationService {
        return ApplicationServiceRegistry.authenticationService
    }

    private struct LocalizedString {
        static let header = NSLocalizedString("app.unlock.header", comment: "Unlock screen header")
    }

    static func create(completion: (() -> Void)? = nil) -> UnlockViewController {
        let vc = StoryboardScene.AppFlow.unlockViewController.instantiate()
        vc.unlockCompletion = completion ?? {}
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = LocalizedString.header
        textInput.delegate = self
        textInput.isSecure = true

        let biometryIcon = authenticationService
            .isAuthenticationMethodSupported(.faceID) ? Asset.faceIdIcon.image : Asset.touchIdIcon.image
        loginWithBiometryButton.setImage(biometryIcon, for: .normal)
        updateBiometryButtonVisibility()
        countdownLabel.setup(time: authenticationService.blockedPeriodDuration,
                             clock: clockService)
        countdownLabel.accessibilityIdentifier = "countdown"
        startCountdownIfNeeded()
    }

    private func startCountdownIfNeeded() {
        guard authenticationService.isAuthenticationBlocked else { return }
        textInput.isEnabled = false
        updateBiometryButtonVisibility()
        countdownLabel.start { [weak self] in
            guard let `self` = self else { return }
            self.textInput.isEnabled = true
            _ = self.textInput.becomeFirstResponder()
        }
    }

    private func updateBiometryButtonVisibility() {
        loginWithBiometryButton.isHidden = !ApplicationServiceRegistry
            .authenticationService
            .isBiometricAuthenticationPossible
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        auhtenticateWithBiometry()
    }

    @IBAction func loginWithBiometry(_ sender: Any) {
        auhtenticateWithBiometry()
    }

    private func auhtenticateWithBiometry() {
        guard !authenticationService.isAuthenticationBlocked else { return }
        authenticationService.authenticateUser {  [unowned self] success in
            DispatchQueue.main.async {
                if success {
                    self.unlockCompletion()
                } else {
                    _ = self.textInput.becomeFirstResponder()
                    self.updateBiometryButtonVisibility()
                }
            }
        }
    }

}

extension UnlockViewController: TextInputDelegate {

    func textInputDidReturn(_ textInput: TextInput) {
        authenticationService.authenticateUser(password: textInput.text!) {
            [unowned self] success in
            DispatchQueue.main.async {
                if success {
                    self.unlockCompletion()
                } else {
                    self.textInput.shake()
                    self.startCountdownIfNeeded()
                }
            }
        }
    }

}
