//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common
import IdentityAccessApplication
import MultisigWalletApplication
import MultisigWalletApplication

protocol SaveMnemonicDelegate: class {
    func saveMnemonicViewControllerDidPressContinue(_ vc: SaveMnemonicViewController)
}

final class SaveMnemonicViewController: UIViewController {

    enum Strings {
        static let title = LocalizedString("recovery_phrase", comment: "Title for setup recovery phrase screen.")
        static let header = LocalizedString("ios_showSeed_header", comment: "Header for setup recovery phrase screen.")
        static let copy = LocalizedString("ios_showSeed_copy", comment: "Make a copy button")
        static let description = LocalizedString("ios_showSeed_description",
                                                 comment: "Description for setup recovery phrase screen.")
        static let warning = LocalizedString("ios_showSeed_warning",
                                             comment: "Warning for setup recovery phrase screen.")
        static let next = LocalizedString("next", comment: "Next button.")
        static let copiedMessage = LocalizedString("copied_to_clipboard", comment: "Copied to clipboard")
    }

    enum RecoveryStrings {
        static let header = LocalizedString("new_seed", comment: "New recovery phrase")
    }

    var recoveryModeEnabled = false

    var screenTitle: String? {
        return recoveryModeEnabled ? nil : Strings.title
    }
    var headerText: String {
        return recoveryModeEnabled ? RecoveryStrings.header : Strings.header
    }

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var mnemonicWrapperView: UIView!
    @IBOutlet weak var mnemonicLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!

    /// If nil, then onboarding tracking will be used. Otherwise, this event.
    var screenTrackingEvent: Trackable?

    private(set) weak var delegate: SaveMnemonicDelegate?
    private var ethereumService: EthereumApplicationService {
        return ApplicationServiceRegistry.ethereumService
    }
    private(set) var account: ExternallyOwnedAccountData!

    static func create(delegate: SaveMnemonicDelegate, isRecoveryMode: Bool = false) -> SaveMnemonicViewController {
        let controller = StoryboardScene.CreateSafe.saveMnemonicViewController.instantiate()
        controller.delegate = delegate
        controller.recoveryModeEnabled = isRecoveryMode
        return controller
    }

    @IBAction func copyToClipboard(_ sender: UIButton) {
        UIPasteboard.general.string = mnemonicLabel.text!
        FeedbackTooltip.show(for: sender, in: view, message: Strings.copiedMessage)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        headerLabel.text = headerText
        configureMnemonic()
        copyButton.setTitle(Strings.copy, for: .normal)
        configureDescriptionAndWarning()
        addNextButton()
    }

    private func configureMnemonic() {
        setUpAccount()
        guard !account.mnemonicWords.isEmpty else {
            mnemonicLabel.text = nil
            dismiss(animated: true)
            return
        }
        mnemonicWrapperView.layer.cornerRadius = 6
        mnemonicLabel.text = account.mnemonicWords.joined(separator: " ")
        mnemonicLabel.accessibilityIdentifier = "mnemonic"
    }

    fileprivate func generateNewAccount() {
        account = ethereumService.generateExternallyOwnedAccount()
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
            generateNewAccount()
        } else {
            if let existingAddress = ApplicationServiceRegistry.walletService.ownerAddress(of: .paperWallet),
                let existingAccount = ethereumService.findExternallyOwnedAccount(by: existingAddress) {
                account = existingAccount
            } else {
                generateNewAccount()
            }
        }
    }

    private func configureDescriptionAndWarning() {
        descriptionLabel.text = Strings.description
        descriptionLabel.accessibilityIdentifier = "description"
        warningLabel.text = Strings.warning
        warningLabel.accessibilityIdentifier = "warning"
    }

    private func addNextButton() {
        let nextButton = UIBarButtonItem(
            title: Strings.next, style: .plain, target: self, action: #selector(confirmMnemonic))
        navigationItem.rightBarButtonItem = nextButton
    }

    @objc func confirmMnemonic() {
        delegate?.saveMnemonicViewControllerDidPressContinue(self)
    }

}
