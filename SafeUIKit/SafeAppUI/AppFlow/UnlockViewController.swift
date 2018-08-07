//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication

class Authenticator {
    var user: String?

    static let instance = Authenticator()

    private init() {}

    public func authenticate(_ request: AuthenticationRequest) throws -> AuthenticationResult {
        let result = try ApplicationServiceRegistry.authenticationService.authenticateUser(request)
        if case AuthenticationResult.success(userID: let userID) = result {
            user = userID
        }
        return result
    }

    public func registerUser(password: String) throws {
        try ApplicationServiceRegistry.authenticationService.registerUser(password: password)
        _ = try authenticate(.password(password))
    }
}

final class UnlockViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var countdownLabel: CountdownLabel!
    @IBOutlet weak var headerLabel: H1Label!
    @IBOutlet weak var textInput: TextInput!
    @IBOutlet weak var loginWithBiometryButton: UIButton!
    var showsCancelButton: Bool = false
    private var unlockCompletion: ((Bool) -> Void)!
    private var clockService: Clock { return ApplicationServiceRegistry.clock }
    private var authenticationService: AuthenticationApplicationService {
        return ApplicationServiceRegistry.authenticationService
    }

    private struct Strings {
        static let header = LocalizedString("app.unlock.header", comment: "Unlock screen header")
        static let cancel = LocalizedString("app.unlock.cancel", comment: "Cancel")
    }

    static func create(completion: ((Bool) -> Void)? = nil) -> UnlockViewController {
        let vc = StoryboardScene.AppFlow.unlockViewController.instantiate()
        vc.unlockCompletion = completion ?? { _ in }
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = Strings.header
        textInput.delegate = self
        textInput.isSecure = true

        let biometryIcon = authenticationService
            .isAuthenticationMethodSupported(.faceID) ? Asset.faceIdIcon.image : Asset.touchIdIcon.image
        loginWithBiometryButton.setImage(biometryIcon, for: .normal)
        updateBiometryButtonVisibility()
        countdownLabel.setup(time: authenticationService.blockedPeriodDuration,
                             clock: clockService)
        countdownLabel.accessibilityIdentifier = "countdown"

        cancelButton.isHidden = !showsCancelButton
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.setTitle(Strings.cancel, for: .normal)
        cancelButton.accessibilityIdentifier = "cancel"

        startCountdownIfNeeded()
    }

    private func startCountdownIfNeeded() {
        guard authenticationService.isAuthenticationBlocked else { return }
        textInput.isEnabled = false
        updateBiometryButtonVisibility()
        countdownLabel.start { [weak self] in
            guard let `self` = self else { return }
            self.textInput.isEnabled = true
            self.focusPasswordField()
        }
    }

    private func updateBiometryButtonVisibility() {
        loginWithBiometryButton.isHidden = !ApplicationServiceRegistry
            .authenticationService
            .isAuthenticationMethodPossible(.biometry)
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
        guard authenticationService.isAuthenticationMethodPossible(.biometry) else {
            focusPasswordField()
            return
        }
        do {
            let result = try Authenticator.instance.authenticate(.biometry())
            if result.isSuccess {
                unlockCompletion(true)
            } else {
                focusPasswordField()
            }
        } catch let e {
            ErrorHandler.showFatalError(log: "Failed to authenticate with biometry", error: e)
        }
    }

    private func focusPasswordField() {
        _ = textInput.becomeFirstResponder()
        updateBiometryButtonVisibility()
    }

    @objc func cancel() {
        unlockCompletion(false)
    }

}

extension UnlockViewController: TextInputDelegate {

    func textInputDidReturn(_ textInput: TextInput) {
        do {
            let result = try Authenticator.instance.authenticate(.password(textInput.text!))
            if result.isSuccess {
                self.unlockCompletion(true)
            } else {
                self.textInput.shake()
                self.startCountdownIfNeeded()
            }
        } catch let e {
            ErrorHandler.showFatalError(log: "Failed to authenticate with password", error: e)
        }
    }

}
