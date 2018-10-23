//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import MultisigWalletApplication
import MultisigWalletApplication

protocol SaveMnemonicDelegate: class {
    func didPressContinue()
}

final class SaveMnemonicViewController: UIViewController {

    enum Strings {
        static let title = LocalizedString("new_safe.setup_recovery.title",
                                           comment: "Title for setup recovery phrase screen.")
        static let header = LocalizedString("new_safe.setup_recovery.header",
                                            comment: "Header for setup recovery phrase screen.")
        static let copy = LocalizedString("new_safe.setup_recovery.copy", comment: "Make a copy button")
        static let description = LocalizedString("new_safe.setup_recovery.description",
                                                 comment: "Description for setup recovery phrase screen.")
        static let warning = LocalizedString("new_safe.setup_recovery.warning",
                                             comment: "Warning for setup recovery phrase screen.")
        static let next = LocalizedString("new_safe.setup_recovery.next",
                                          comment: "Next button.")
    }

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var mnemonicWrapperView: UIView!
    @IBOutlet weak var mnemonicLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!

    private(set) weak var delegate: SaveMnemonicDelegate?
    private var ethereumService: EthereumApplicationService {
        return ApplicationServiceRegistry.ethereumService
    }
    private(set) var account: ExternallyOwnedAccountData!

    static func create(delegate: SaveMnemonicDelegate) -> SaveMnemonicViewController {
        let controller = StoryboardScene.NewSafe.saveMnemonicViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    @IBAction func copyToClipboard(_ sender: Any) {
        UIPasteboard.general.string = mnemonicLabel.text!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        headerLabel.text = Strings.header
        configureMnemonic()
        copyButton.setTitle(Strings.copy, for: .normal)
        configureDescriptionAndWarning()
        addNextButton()
    }

    private func configureMnemonic() {
        if let existingAddress = ApplicationServiceRegistry.walletService.ownerAddress(of: .paperWallet),
            let existingAccount = ethereumService.findExternallyOwnedAccount(by: existingAddress) {
            account = existingAccount
        } else {
            account = ethereumService.generateExternallyOwnedAccount()
        }
        guard !account.mnemonicWords.isEmpty else {
            mnemonicLabel.text = nil
            dismiss(animated: true)
            return
        }
        mnemonicWrapperView.layer.cornerRadius = 6
        mnemonicLabel.text = account.mnemonicWords.joined(separator: " ")
        mnemonicLabel.accessibilityIdentifier = "mnemonic"
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
        delegate?.didPressContinue()
    }

}
