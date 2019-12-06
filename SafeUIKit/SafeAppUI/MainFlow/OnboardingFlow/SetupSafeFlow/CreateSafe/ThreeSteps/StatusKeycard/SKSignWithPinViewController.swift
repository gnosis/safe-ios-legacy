//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

class SKSignWithPinViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!

    @IBOutlet weak var pinField: VerifiableInput!

    var confirmButton: UIBarButtonItem!

    private var keyboardBehavior: KeyboardAvoidingBehavior!

    private var onCompletion: (() -> Void)!
    private var transactionID: String!

    private static let pinLength = 6

    enum Strings {
        static let confirm = LocalizedString("confirm", comment: "Confirm")
        static let title = LocalizedString("keycard_authentication", comment: "Keycard authentication")
        static let text = LocalizedString("enter_pin", comment: "Enter the PIN.")
        static let placeholder = LocalizedString("pin", comment: "PIN")

        static let notEmptyRule = LocalizedString("not_empty", comment: "Not empty")
        static let onlyDigitsRule = LocalizedString("only_digits", comment: "Use digits only")

        static func exactlyNDigits(n: Int) -> String {
            String(format: LocalizedString("exactly_x_digits", comment: "Exactly x digits"), n)
        }

    }

    static func create(transactionID: String, onCompletion: @escaping () -> Void) -> SKSignWithPinViewController {
        let controller = StoryboardScene.CreateSafe.skSignWithPinViewController.instantiate()
        controller.onCompletion = onCompletion
        controller.transactionID = transactionID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.attributedText = NSAttributedString(string: Strings.title, style: HeaderStyle())
        textLabel.attributedText = NSAttributedString(string: Strings.text, style: DescriptionStyle())

        confirmButton = UIBarButtonItem(title: Strings.confirm,
                                        style: .done,
                                        target: self,
                                        action: #selector(signWithKeycard))
        navigationItem.rightBarButtonItem = confirmButton

        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)

        pinField.isPassword = true
        pinField.style = .white
        pinField.textInput.placeholder = Strings.placeholder
        pinField.textInput.keyboardType = .numberPad
        pinField.showErrorsOnly = true
        pinField.delegate = self

        pinField.addRule(Strings.notEmptyRule) { !$0.isEmpty }

        pinField.addRule(Strings.onlyDigitsRule) { text in
            return text.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }

        pinField.addRule(Strings.exactlyNDigits(n: SKSignWithPinViewController.pinLength)) { text in
            return text.count == SKSignWithPinViewController.pinLength
        }

        _ = pinField.textInput.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardBehavior.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(TwoFATrackingEvent.signWithKeycardPIN)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardBehavior.stop()
    }

    var signInProgress = false

    @objc func signWithKeycard() {
        guard pinField.isValid else {
            pinField.shake()
            return
        }
        guard !signInProgress else { return }
        signInProgress = true

        confirmButton.isEnabled = false

        assert(pinField.text != nil)
        assert(pinField.text?.count == SKSignWithPinViewController.pinLength)
        let pin = pinField.text!

        assert(transactionID != nil)
        assert(onCompletion != nil)
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            do {
                try ApplicationServiceRegistry.keycardService.signTransaction(id: self.transactionID, pin: pin)
                self.signInProgress = false

                DispatchQueue.main.async {
                    self.onCompletion?()

                    // dismiss the sign controller
                    if self.presentingViewController != nil {
                        self.dismiss(animated: true, completion: nil)
                    } else if let nav = self.navigationController, let prevVC = nav.viewController(before: self) {
                        nav.popToViewController(prevVC, animated: true)
                    }
                }
            } catch {
                self.signInProgress = false
                DispatchQueue.main.async {
                    self.confirmButton.isEnabled = true
                    self.showError(error)
                }
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func showError(_ error: Error) {
        switch error {

        case KeycardApplicationService.Error.invalidPin(let attempts):
            let errorText = String(format: LocalizedString("incorrect_pin_x_attempts", comment: "Wrong pin"), attempts)
            pinField.setExplicitError(errorText)

        case KeycardApplicationService.Error.keycardBlocked:
            #if DEBUG
            askToUnblock()
            #else
            present(UIAlertController.keycardBlocked(getInTouch: showGetInTouch), animated: true)
            #endif

        case KeycardApplicationService.Error.invalidPUK(let attempts):
            let errorText = String(format: LocalizedString("incorrect_puk_attempts", comment: "Wrong PUK"), attempts)
            presentError(errorText)

        case KeycardApplicationService.Error.keycardLost:
            presentError(LocalizedString("error_keycard_lost", comment: "Keycard is lost"))

        case KeycardApplicationService.Error.keycardKeyNotFound:
            presentError(LocalizedString("error_keycard_key_not_found", comment: "Key not found"))

        case KeycardApplicationService.Error.keycardNotPaired:
            presentError(LocalizedString("error_keycard_pairing_not_found", comment: "Pairing not found"))

        case KeycardApplicationService.Error.unknownKeycard:
            presentError(LocalizedString("error_keycard_unknown", comment: "Keycard unknown"))

        case KeycardApplicationService.Error.unknownMasterKey:
            presentError(LocalizedString("error_keycard_master_key_unknown", comment: "Unknown master key"))

        case KeycardApplicationService.Error.keycardPairingBecameInvalid:
            presentError(LocalizedString("error_keycard_pairing_invalid", comment: "Pairing invalid"))

        case KeycardApplicationService.Error.signingFailed:
            presentError(LocalizedString("error_keycard_signing_failed", comment: "Signing failed"))

        case KeycardApplicationService.Error.invalidSignature:
            presentError(LocalizedString("error_keycard_invalid_signature", comment: "Signature invalid"))

        case KeycardApplicationService.Error.invalidSigner:
            presentError(LocalizedString("error_keycard_invalid_signer", comment: "Signer invalid"))

        case KeycardApplicationService.Error.userCancelled,
             KeycardApplicationService.Error.timeout:
            // do nothing
            break

        default:
            present(UIAlertController.genericError(), animated: true)
        }
    }

    private func presentError(_ message: String) {
        present(UIAlertController.operationFailed(message: message), animated: true, completion: nil)
    }

    func showGetInTouch() {
        show(GetInTouchTableViewController(), sender: self)
    }

    #if DEBUG
    func askToUnblock() {
        let title = LocalizedString("keycard_blocked", comment: "Blocked")
        let message = "Do you want to unblock?"
        let yes = "Yes"
        var alert: UIAlertController!
        alert = UIAlertController.create(title: title, message: message)
            .withCloseAction()
            .withDefaultAction(title: yes) { [unowned self] in
                self.unblock()
        }
        present(alert, animated: true)
    }

    func unblock() {
        let title = "Unblock with PUK"
        let message = "Enter PUK and new PIN"
        let button = "Unblock"

        let alert = UIAlertController.create(title: title, message: message)
            .withCloseAction()

        alert.addTextField { pukField in
            pukField.placeholder = "PUK"
            pukField.isSecureTextEntry = true
        }

        alert.addTextField { pinField in
            pinField.placeholder = "New PIN"
            pinField.isSecureTextEntry = true
        }

        alert.addAction(UIAlertAction(title: button, style: .default) { [unowned alert, weak self] action in
            guard let `self` = self else { return }
            let puk = alert.textFields![0].text ?? ""
            let pin = alert.textFields![1].text ?? ""

            guard puk.count == 12 && puk.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
                alert.dismiss(animated: true) {
                    self.presentError("PUK must be exactly 12 digits.")
                }
                return
            }

            guard pin.count == 6 && pin.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
                alert.dismiss(animated: true) {
                    self.presentError("PIN must be exactly 6 digits")
                }
                return
            }

            alert.dismiss(animated: true) {
                DispatchQueue.global().async {
                    do {
                        try ApplicationServiceRegistry.keycardService.unblock(puk: puk, pin: pin)
                    } catch {
                        DispatchQueue.main.async {
                            self.showError(error)
                        }
                    }
                }
            }
        })

        present(alert, animated: true, completion: nil)
    }
    #endif

}

extension SKSignWithPinViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        signWithKeycard()
    }

    func verifiableInputDidBeginEditing(_ verifiableInput: VerifiableInput) {
        keyboardBehavior.activeTextField = verifiableInput.textInput
    }

}
