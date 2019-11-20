//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common
import IdentityAccessApplication
import MultisigWalletApplication

protocol ShowSeedViewControllerDelegate: class {
    func showSeedViewControllerDidPressContinue(_ controller: ShowSeedViewController)
}

class ShowSeedViewController: UIViewController {

    enum Strings {
        static let title = LocalizedString("recovery_phrase", comment: "Title for setup recovery phrase screen.")
        static let header = LocalizedString("layout_setup_recovery_phrase_title",
                                            comment: "Header for setup recovery phrase screen.")
        static let subheader = LocalizedString("layout_setup_recovery_phrase_description", comment: "Tip")
        static let copy = LocalizedString("i_have_a_copy", comment: "I have a copy")
    }

    enum RecoveryStrings {
        static let header = LocalizedString("new_seed", comment: "New recovery phrase")
    }

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subheaderLabel: UILabel!
    @IBOutlet weak var seedPhraseView: SeedPhraseView!
    @IBOutlet weak var actionButton: StandardButton!

    weak var delegate: ShowSeedViewControllerDelegate?
    var screenTrackingEvent: Trackable?
    var recoveryModeEnabled = false
    private(set) var account: ExternallyOwnedAccountData?

    static func create(delegate: ShowSeedViewControllerDelegate,
                       isRecoveryMode: Bool = false) -> ShowSeedViewController {
        let controller = StoryboardScene.SeedPhrase.showSeedViewController.instantiate()
        controller.delegate = delegate
        controller.recoveryModeEnabled = isRecoveryMode
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = recoveryModeEnabled ? nil : Strings.title
        headerLabel.text = recoveryModeEnabled ? RecoveryStrings.header : Strings.header
        subheaderLabel.text = Strings.subheader

        headerLabel.textColor = ColorName.darkBlue.color

        subheaderLabel.textColor = ColorName.darkGrey.color

        actionButton.style = .filled
        actionButton.setTitle(Strings.copy, for: .normal)

        setUpAccount()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        seedPhraseView.update()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomBackButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = screenTrackingEvent {
            trackEvent(event)
        } else {
            trackEvent(OnboardingEvent.recoveryPhrase)
            trackEvent(OnboardingTrackingEvent.showSeed)
        }
    }

    func willBeDismissed() {
        guard recoveryModeEnabled, let account = account else { return }
        DispatchQueue.global().async {
            ApplicationServiceRegistry.ethereumService.removeExternallyOwnedAccount(address: account.address)
        }
    }

    private func setUpAccount() {
        if recoveryModeEnabled {
            account = ApplicationServiceRegistry.ethereumService.generateExternallyOwnedAccount()
        } else {
            if let existingAddress = ApplicationServiceRegistry.walletService.ownerAddress(of: .paperWallet),
                let existingAccount = ApplicationServiceRegistry.ethereumService
                    .findExternallyOwnedAccount(by: existingAddress) {
                account = existingAccount
            } else {
                account = ApplicationServiceRegistry.ethereumService.generateExternallyOwnedAccount()
            }
        }
        guard let mnemonic = account?.mnemonicWords, !mnemonic.isEmpty else {
            dismiss(animated: true)
            return
        }
        seedPhraseView.words = mnemonic.enumerated().map {
            SeedWord(index: $0.offset, value: $0.element, style: .normal)
        }
    }

    @IBAction func didTapActionButton(_ sender: Any) {
        delegate?.showSeedViewControllerDidPressContinue(self)
    }

}
