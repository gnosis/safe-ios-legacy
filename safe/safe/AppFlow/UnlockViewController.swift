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
    private var account: AccountProtocol!
    private var clockService: SystemClockServiceProtocol!
    private var blockPeriod: TimeInterval!

    private struct LocalizedString {
        static let header = NSLocalizedString("app.unlock.header", comment: "Unlock screen header")
    }

    static func create(account: AccountProtocol,
                       clockService: SystemClockServiceProtocol = SystemClockService(),
                       blockPeriod: TimeInterval = 15,
                       completion: @escaping () -> Void) -> UnlockViewController {
        let vc = StoryboardScene.AppFlow.unlockViewController.instantiate()
        vc.account = account
        vc.clockService = clockService
        vc.blockPeriod = blockPeriod
        vc.unlockCompletion = completion
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = LocalizedString.header
        textInput.delegate = self
        let biometryIcon: UIImage = account.isBiometryFaceID ? Asset.faceIdIcon.image : Asset.touchIdIcon.image
        loginWithBiometryButton.setImage(biometryIcon, for: .normal)
        updateBiometryButtonVisibility()
        countdownLabel.setup(time: blockPeriod, clock: clockService)
        startCountdownIfNeeded()
    }

    private func startCountdownIfNeeded() {
        guard account.isBlocked else { return }
        textInput.isEnabled = false
        updateBiometryButtonVisibility()
        countdownLabel.start { [weak self] in
            guard let `self` = self else { return }
            self.textInput.isEnabled = true
            _ = self.textInput.becomeFirstResponder()
        }
    }

    private func updateBiometryButtonVisibility() {
        loginWithBiometryButton.isHidden = !account.isBiometryAuthenticationAvailable || account.isBlocked
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        auhtenticateWithBiometry()
    }

    @IBAction func loginWithBiometry(_ sender: Any) {
        auhtenticateWithBiometry()
    }

    private func auhtenticateWithBiometry() {
        guard !account.isBlocked else { return }
        account.authenticateWithBiometry { [unowned self] success in
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
        let success = account.authenticateWithPassword(textInput.text!)
        if success {
            unlockCompletion()
        } else {
            // TODO: 16/03/18 show error to user
            startCountdownIfNeeded()
        }
    }

}
