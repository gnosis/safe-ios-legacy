//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol OnboardingCreateOrRestoreViewControllerDelegate: class {
    func didSelectNewSafe()
    func didSelectRecoverSafe()
    func openMenu()
}

class OnboardingCreateOrRestoreViewController: UIViewController {

    enum Strings {
        static let header = LocalizedString("setup_successful", comment: "Set up safe options screen title")
        static let newSafe = LocalizedString("create_safe", comment: "New safe button")
        static let restoreSafe = LocalizedString("recover_safe", comment: "Restore safe button")
    }

    @IBOutlet var backgroundView: BackgroundImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var newSafeButton: StandardButton!
    @IBOutlet weak var recoverSafeButton: StandardButton!
    private weak var delegate: OnboardingCreateOrRestoreViewControllerDelegate?

    static func create(delegate: OnboardingCreateOrRestoreViewControllerDelegate)
        -> OnboardingCreateOrRestoreViewController {
            let vc = StoryboardScene.SetupSafe.setupSafeOptionsViewController.instantiate()
            vc.delegate = delegate
            return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.attributedText = NSAttributedString(string: Strings.header, style: HeaderStyle())
        newSafeButton.style = .filled
        newSafeButton.setTitle(Strings.newSafe, for: .normal)
        recoverSafeButton.style = .plain
        recoverSafeButton.setTitle(Strings.restoreSafe, for: .normal)
        navigationItem.setRightBarButton(UIBarButtonItem.menuButton(target: self, action: #selector(openMenu)),
                                         animated: false)
    }

    @objc func openMenu(_ sender: Any) {
        delegate?.openMenu()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = Asset.shadow.image
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingTrackingEvent.createOrRestore)
    }

    @IBAction func createNewSafe(_ sender: UIButton) {
        guard sender.isEnabled else { return }
        sender.isEnabled = false
        ApplicationServiceRegistry.walletService.cleanUpDrafts()
        ApplicationServiceRegistry.walletService.createNewDraftWallet()
        delegate?.didSelectNewSafe()
        sender.isEnabled = true
    }

    @IBAction func recoverExistingSafe(_ sender: UIButton) {
        guard sender.isEnabled else { return }
        sender.isEnabled = false

        if !ApplicationServiceRegistry.walletService.hasSelectedWallet {
            ApplicationServiceRegistry.recoveryService.createRecoverDraftWallet()
        } else {
            ApplicationServiceRegistry.recoveryService.prepareForRecovery()
        }
        delegate?.didSelectRecoverSafe()

        sender.isEnabled = true
    }


    class HeaderStyle: AttributedStringStyle {

        override var minimumLineHeight: Double { return 32 }
        override var maximumLineHeight: Double { return 32 }
        override var fontColor: UIColor { return ColorName.darkBlue.color }
        override var fontSize: Double { return 20 }
        override var alignment: NSTextAlignment { return .center }

    }

}
