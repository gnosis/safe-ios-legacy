//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import EthereumApplication
import MultisigWalletApplication

protocol SaveMnemonicDelegate: class {
    func didPressContinue()
}

final class SaveMnemonicViewController: UIViewController {

    private struct Strings {
        static let title = LocalizedString("new_safe.paper_wallet.title",
                                           comment: "Title for store paper wallet screen")
        static let copy = LocalizedString("new_safe.paper_wallet.copy", comment: "Copy Button")
        static let description = LocalizedString("new_safe.paper_wallet.description",
                                                 comment: "Description for store paper wallet screen")
        static let `continue` = LocalizedString("new_safe.paper_wallet.continue",
                                                comment: "Continue button for store paper wallet screen")
    }

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var mnemonicCopyableLabel: UILabel!
    @IBOutlet weak var copyToClipboardButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!

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

    @IBAction func continuePressed(_ sender: Any) {
        delegate?.didPressContinue()
    }

    @IBAction func copyToClipboard(_ sender: Any) {
        UIPasteboard.general.string = mnemonicCopyableLabel.text!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            if let existingAddress = ApplicationServiceRegistry.walletService.ownerAddress(of: .paperWallet),
                let existingAccount = try ethereumService.findExternallyOwnedAccount(by: existingAddress) {
                account = existingAccount
            } else {
                account = try ethereumService.generateExternallyOwnedAccount()
            }
        } catch let e {
            ErrorHandler.showError(log: "Failed to generate paper wallet account", error: e)
            dismiss(animated: true)
            return
        }
        guard !account.mnemonicWords.isEmpty else {
            mnemonicCopyableLabel.text = nil
            dismiss(animated: true)
            return
        }
        titleLabel.text = Strings.title
        mnemonicCopyableLabel.text = account.mnemonicWords.joined(separator: " ")
        mnemonicCopyableLabel.accessibilityIdentifier = "mnemonic"
        copyToClipboardButton.setTitle(Strings.copy, for: .normal)
        descriptionLabel.text = Strings.description
        descriptionLabel.accessibilityIdentifier = "description"
        continueButton.setTitle(Strings.continue, for: .normal)
    }

}
