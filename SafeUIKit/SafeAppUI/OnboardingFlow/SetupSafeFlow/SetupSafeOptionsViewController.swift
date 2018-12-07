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
        static let header = LocalizedString("onboarding.setup_safe.info", comment: "Set up safe options screen title")
        static let newSafe = LocalizedString("onboarding.setup_safe.new_safe", comment: "New safe button")
        static let restoreSafe = LocalizedString("onboarding.setup_safe.restore", comment: "Restore safe button")
    }

    @IBOutlet var backgroundView: BackgroundImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var newSafeButton: BigBorderedButton!
    @IBOutlet weak var recoverSafeButton: BigBorderedButton!
    private weak var delegate: SetupSafeOptionsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.isDark = true
        headerLabel.text = Strings.header
        headerLabel.textColor = .white
        newSafeButton.setTitle(Strings.newSafe, for: .normal)
        recoverSafeButton.setTitle(Strings.restoreSafe, for: .normal)
    }

    @IBAction func createNewSafe(_ sender: Any) {
        if !ApplicationServiceRegistry.walletService.hasSelectedWallet {
            ApplicationServiceRegistry.walletService.createNewDraftWallet()
        }
        delegate?.didSelectNewSafe()
    }

    @IBAction func recoverExistingSafe(_ sender: Any) {
        delegate?.didSelectRecoverSafe()
    }

    static func create(delegate: SetupSafeOptionsDelegate) -> SetupSafeOptionsViewController {
        let vc = StoryboardScene.SetupSafe.setupSafeOptionsViewController.instantiate()
        vc.delegate = delegate
        return vc
    }


}
