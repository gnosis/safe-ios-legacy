//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessApplication

protocol SetupRecoveryOptionDelegate: class {
    func didSelectMnemonicRecovery()
}

class RecoveryOptionsViewController: UIViewController {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var mnemonicRecoveryButton: BigButton!
    @IBOutlet weak var otherRecoveryOptionTemporaryButton: BigButton!
    var nextButton: UIBarButtonItem {
        return navigationItem.rightBarButtonItem!
    }

    @IBAction func setupMnemonicRecovery(_ sender: Any) {
        delegate?.didSelectMnemonicRecovery()
    }

    weak var delegate: SetupRecoveryOptionDelegate?

    static func create(delegate: SetupRecoveryOptionDelegate) -> RecoveryOptionsViewController {
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
        nextButton.isEnabled = ApplicationServiceRegistry.identityService.isRecoverySet
    }

}
