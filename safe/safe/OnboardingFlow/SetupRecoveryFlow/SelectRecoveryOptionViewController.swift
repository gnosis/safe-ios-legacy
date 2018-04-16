//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessApplication

protocol RecoveryOptionsDelegate: class {
    func didSelectMnemonicRecovery()
}

class RecoveryOptionsViewController: UIViewController {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var mnemonicRecoveryButton: BigButton!
    @IBOutlet weak var otherRecoveryOptionTemporaryButton: BigButton!
    weak var delegate: RecoveryOptionsDelegate?

    static func create(delegate: RecoveryOptionsDelegate) -> RecoveryOptionsViewController {
        let controller = StoryboardScene.SetupRecovery.selectRecoveryOptionViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("onboarding.recovery_options.title",
                                            comment: "Title for selecting recovery option screen")
        otherRecoveryOptionTemporaryButton.isEnabled = false
        mnemonicRecoveryButton.checkmarkStatus = .normal
        otherRecoveryOptionTemporaryButton.checkmarkStatus = .normal
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func setupMnemonicRecovery(_ sender: Any) {
        delegate?.didSelectMnemonicRecovery()
    }

}
