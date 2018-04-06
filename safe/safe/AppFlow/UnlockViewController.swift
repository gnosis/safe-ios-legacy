//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

final class UnlockViewController: UIViewController {

    @IBOutlet weak var countdownLabel: CountdownLabel!
    @IBOutlet weak var headerLabel: H1Label!
    @IBOutlet weak var textInput: TextInput!
    @IBOutlet weak var loginWithBiometryButton: UIButton!
    private var unlockCompletion: (() -> Void)!
    private var clockService: SystemClockServiceProtocol!

    private struct LocalizedString {
        static let header = NSLocalizedString("app.unlock.header", comment: "Unlock screen header")
    }

    static func create(clockService: SystemClockServiceProtocol = SystemClockService(),
                       completion: (() -> Void)? = nil) -> UnlockViewController {
        let vc = StoryboardScene.AppFlow.unlockViewController.instantiate()
        vc.clockService = clockService
        vc.unlockCompletion = completion ?? {}
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = LocalizedString.header
        textInput.delegate = self
        textInput.isSecure = true

        let biometryIcon = ApplicationServiceRegistry
            .authenticationService()
            .isAuthenticationMethodSupported(.faceID) ? Asset.faceIdIcon.image : Asset.touchIdIcon.image
        loginWithBiometryButton.setImage(biometryIcon, for: .normal)
        updateBiometryButtonVisibility()
        countdownLabel.setup(time: ApplicationServiceRegistry.authenticationService().blockedPeriodDuration,
                             clock: clockService)
        countdownLabel.accessibilityIdentifier = "countdown"
        startCountdownIfNeeded()
    }

    private func startCountdownIfNeeded() {
        guard ApplicationServiceRegistry.authenticationService().isAuthenticationBlocked() else { return }
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
            .authenticationService()
            .isBiometricAuthenticationPossible()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        auhtenticateWithBiometry()
    }

    @IBAction func loginWithBiometry(_ sender: Any) {
        auhtenticateWithBiometry()
    }

    private func auhtenticateWithBiometry() {
        ApplicationServiceRegistry.authenticationService().authenticateUser {  [unowned self] success in
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

    func textInputDidReturn() {
        ApplicationServiceRegistry.authenticationService().authenticateUser(password: textInput.text!) {
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
