//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol SetupSafeOptionsDelegate: class {
    func didSelectNewSafe()
    func didSelectRecoverSafe()
}

class SetupSafeOptionsViewController: UIViewController {

    enum Strings {
        static let header = LocalizedString("setup_successful", comment: "Set up safe options screen title")
        static let newSafe = LocalizedString("create_safe", comment: "New safe button")
        static let restoreSafe = LocalizedString("recover_safe", comment: "Restore safe button")
    }

    @IBOutlet var backgroundView: BackgroundImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var newSafeButton: StandardButton!
    @IBOutlet weak var recoverSafeButton: StandardButton!
    private weak var delegate: SetupSafeOptionsDelegate?

    static func create(delegate: SetupSafeOptionsDelegate) -> SetupSafeOptionsViewController {
        let vc = StoryboardScene.SetupSafe.setupSafeOptionsViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = Strings.header
        headerLabel.textColor = .white
        newSafeButton.setTitle(Strings.newSafe, for: .normal)
        recoverSafeButton.setTitle(Strings.restoreSafe, for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingTrackingEvent.createOrRestore)
    }

    @IBAction func createNewSafe(_ sender: Any) {
        if !ApplicationServiceRegistry.walletService.hasSelectedWallet {
            ApplicationServiceRegistry.walletService.createNewDraftWallet()
        } else {
            ApplicationServiceRegistry.walletService.prepareForCreation()
        }
        delegate?.didSelectNewSafe()
    }

    @IBAction func recoverExistingSafe(_ sender: Any) {
        if !ApplicationServiceRegistry.walletService.hasSelectedWallet {
            ApplicationServiceRegistry.recoveryService.createRecoverDraftWallet()
        } else {
            ApplicationServiceRegistry.recoveryService.prepareForRecovery()
        }
        delegate?.didSelectRecoverSafe()
    }

}
