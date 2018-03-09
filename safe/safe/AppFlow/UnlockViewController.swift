//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

protocol UnlockViewControllerDelegate: class {
    func didLogIn()
}

final class UnlockViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textInput: TextInput!
    @IBOutlet weak var loginWithBiometryButton: UIButton!
    private weak var delegate: UnlockViewControllerDelegate?
    private var account: AccountProtocol!

    static func create(account: AccountProtocol, delegate: UnlockViewControllerDelegate?) -> UnlockViewController {
        let vc = StoryboardScene.AppFlow.unlockViewController.instantiate()
        vc.account = account
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textInput.delegate = self
        updateBiometryButtonVisibility()
    }

    private func updateBiometryButtonVisibility() {
        loginWithBiometryButton.isHidden = !account.isBiometryAuthenticationAvailable
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        auhtenticateWithBiometry()
    }

    @IBAction func loginWithBiometry(_ sender: Any) {
        auhtenticateWithBiometry()
    }

    private func auhtenticateWithBiometry() {
        account.authenticateWithBiometry { [unowned self] success in
            DispatchQueue.main.async {
                if success {
                    self.delegate?.didLogIn()
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
            delegate?.didLogIn()
        }
    }

}
