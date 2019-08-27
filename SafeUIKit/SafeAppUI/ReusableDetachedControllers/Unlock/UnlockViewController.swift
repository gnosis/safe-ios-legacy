//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import Common

public final class UnlockViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var tryAgainLabel: UILabel!
    @IBOutlet weak var countdownStack: UIStackView!
    @IBOutlet weak var backgroundImageView: BackgroundImageView!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var countdownLabel: CountdownLabel!
    @IBOutlet weak var verifiableInput: VerifiableInput!
    @IBOutlet weak var loginWithBiometryButton: UIButton!
    @IBOutlet weak var biometryExplanationLabel: UILabel!
    @IBOutlet weak var biometryStackView: UIStackView!
    public var showsCancelButton: Bool = false
    private var unlockCompletion: ((Bool) -> Void)!
    private var clockService: Clock { return ApplicationServiceRegistry.clock }
    private var authenticationService: AuthenticationApplicationService {
        return ApplicationServiceRegistry.authenticationService
    }

    private enum Strings {
        static let tryAgain = LocalizedString("try_again_in", comment: "Try again in")
        static let cancel = LocalizedString("cancel", comment: "Cancel")
        static let passwordPlaceholder = LocalizedString("password", comment: "Password field placeholder")
        static let faceIDInfo = LocalizedString("use_faceid_to_unlock", comment: "Face ID button explanation")
        static let touchIDInfo = LocalizedString("use_touchid_to_unlock", comment: "Touch ID button explanation")
    }

    public static func create(completion: ((Bool) -> Void)? = nil) -> UnlockViewController {
        let vc = StoryboardScene.Unlock.unlockViewController.instantiate()
        vc.unlockCompletion = completion ?? { _ in }
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        verifiableInput.delegate = self
        verifiableInput.isSecure = true
        verifiableInput.style = .opaqueWhite
        verifiableInput.accessibilityIdentifier = "unlock.password"
        verifiableInput.textInput.placeholder = Strings.passwordPlaceholder

        let isFaceID = authenticationService.isAuthenticationMethodSupported(.faceID)
        let biometryIcon = isFaceID ? Asset.UnlockScreen.faceIdIcon.image : Asset.UnlockScreen.touchIdIcon.image
        loginWithBiometryButton.setImage(biometryIcon, for: .normal)
        loginWithBiometryButton.tintColor = ColorName.darkBlue.color

        biometryExplanationLabel.text = isFaceID ? Strings.faceIDInfo : Strings.touchIDInfo
        biometryExplanationLabel.textColor = ColorName.darkBlue.color
        biometryExplanationLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)

        updateBiometryButtonVisibility()

        tryAgainLabel.textColor = ColorName.darkBlue.color
        tryAgainLabel.text = Strings.tryAgain
        tryAgainLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)

        countdownLabel.setup(time: authenticationService.blockedPeriodDuration,
                             clock: clockService)
        countdownLabel.textColor = ColorName.darkBlue.color
        countdownLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        countdownLabel.accessibilityIdentifier = "countdown"

        cancelButton.isHidden = !showsCancelButton
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.setTitle(Strings.cancel, for: .normal)
        cancelButton.setTitleColor(ColorName.darkBlue.color, for: .normal)
        cancelButton.accessibilityIdentifier = "cancel"

        startCountdownIfNeeded()
        subscribeForKeyboardUpdates()
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

    @discardableResult
    private func startCountdownIfNeeded() -> Bool {
        guard authenticationService.isAuthenticationBlocked else {
            countdownStack.isHidden = true
            return false
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
        return true
    }

    private func updateBiometryButtonVisibility() {
        biometryStackView.isHidden = !ApplicationServiceRegistry
            .authenticationService
            .isAuthenticationMethodPossible(.biometry)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        auhtenticateWithBiometry()
        trackEvent(MainTrackingEvent.unlock)
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
        DispatchQueue.global.async {
            do {
                let result = try Authenticator.instance.authenticate(.biometry())
                DispatchQueue.main.async {
                    if result.isSuccess {
                        self.unlockCompletion(true)
                    } else if !self.startCountdownIfNeeded() {
                        self.focusPasswordField()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.focusPasswordField()
                    ApplicationServiceRegistry.logger.error("Failed to authenticate with biometry: \(error)",
                        error: error)
                }
            }
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
