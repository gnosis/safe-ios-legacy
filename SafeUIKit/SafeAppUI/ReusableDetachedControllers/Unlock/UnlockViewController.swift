//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import Common

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

public final class UnlockViewController: UIViewController {

    @IBOutlet weak var tryAgainLabel: UILabel!
    @IBOutlet weak var countdownStack: UIStackView!
    @IBOutlet weak var backgroundImageView: BackgroundImageView!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var countdownLabel: CountdownLabel!
    @IBOutlet weak var verifiableInput: VerifiableInput!
    @IBOutlet weak var loginWithBiometryButton: UIButton!
    public var showsCancelButton: Bool = false
    private var unlockCompletion: ((Bool) -> Void)!
    private var clockService: Clock { return ApplicationServiceRegistry.clock }
    private var authenticationService: AuthenticationApplicationService {
        return ApplicationServiceRegistry.authenticationService
    }

    private struct Strings {
        static let tryAgain = LocalizedString("app.unlock.tryagain", comment: "Try again in")
        static let cancel = LocalizedString("app.unlock.cancel", comment: "Cancel")
    }

    public static func create(completion: ((Bool) -> Void)? = nil) -> UnlockViewController {
        let vc = StoryboardScene.Unlock.unlockViewController.instantiate()
        vc.unlockCompletion = completion ?? { _ in }
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.isDark = true

        verifiableInput.delegate = self
        verifiableInput.isSecure = true
        verifiableInput.style = .dimmed

        let biometryIcon = authenticationService.isAuthenticationMethodSupported(.faceID) ?
            Asset.UnlockScreen.faceIdIcon.image :
            Asset.UnlockScreen.touchIdIcon.image
        loginWithBiometryButton.setImage(biometryIcon, for: .normal)
        updateBiometryButtonVisibility()

        tryAgainLabel.textColor = ColorName.paleGreyThree.color
        tryAgainLabel.text = Strings.tryAgain
        tryAgainLabel.font = UIFont.systemFont(ofSize: 15)
        countdownLabel.setup(time: authenticationService.blockedPeriodDuration,
                             clock: clockService)
        countdownLabel.textColor = ColorName.paleGreyThree.color
        countdownLabel.font = UIFont.systemFont(ofSize: 20)
        countdownLabel.accessibilityIdentifier = "countdown"

        cancelButton.isHidden = !showsCancelButton
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.setTitle(Strings.cancel, for: .normal)
        cancelButton.accessibilityIdentifier = "cancel"

        startCountdownIfNeeded()
        subscribeForKeyboardUpdates()

        Tracker.shared.track(view: .test)
    }

    private func subscribeForKeyboardUpdates() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willChangeKeyboard(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willChangeKeyboard(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func willChangeKeyboard(_ notification: NSNotification) {
        guard let animationCurveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRaw),
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let endingKeyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            else {
                return
        }
        let contentViewBottomOffset: CGFloat
        if notification.name == UIResponder.keyboardWillShowNotification {
            let keyboardFrameInScreenCoordinates = endingKeyboardValue.cgRectValue
            let keyboardFrameInViewCoordinates = view.convertFromScreenCoordinates(keyboardFrameInScreenCoordinates)
            contentViewBottomOffset = view.bounds.maxY - keyboardFrameInViewCoordinates.minY
        } else {
            contentViewBottomOffset = 0
        }
        // see https://is.gd/qcYyqL
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve)
        contentViewBottomConstraint.constant = contentViewBottomOffset
        view.layoutIfNeeded()
        UIView.commitAnimations()
    }

    private func startCountdownIfNeeded() {
        guard authenticationService.isAuthenticationBlocked else {
            countdownStack.isHidden = true
            return
        }
        countdownStack.isHidden = false
        verifiableInput.isEnabled = false
        updateBiometryButtonVisibility()
        countdownLabel.start { [weak self] in
            guard let `self` = self else { return }
            self.verifiableInput.isEnabled = true
            self.countdownStack.isHidden = true
            self.focusPasswordField()
        }
    }

    private func updateBiometryButtonVisibility() {
        loginWithBiometryButton.isHidden = !ApplicationServiceRegistry
            .authenticationService
            .isAuthenticationMethodPossible(.biometry)
    }

    override public func viewDidAppear(_ animated: Bool) {
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
        _ = verifiableInput.becomeFirstResponder()
        updateBiometryButtonVisibility()
    }

    @objc func cancel() {
        unlockCompletion(false)
    }

}

extension UIView {

    func convertFromScreenCoordinates(_ rect: CGRect) -> CGRect {
        guard let window = self.window else { return rect }
        let inWindowCoordinates = window.convert(rect, from: nil)
        let inViewCoordinates = convert(inWindowCoordinates, from: nil)
        return inViewCoordinates
    }
}

extension UnlockViewController: VerifiableInputDelegate {

    public func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        do {
            let result = try Authenticator.instance.authenticate(.password(verifiableInput.text!))
            if result.isSuccess {
                self.unlockCompletion(true)
            } else {
                verifiableInput.shake()
                self.startCountdownIfNeeded()
            }
        } catch let e {
            ErrorHandler.showFatalError(log: "Failed to authenticate with password", error: e)
        }
    }

}
