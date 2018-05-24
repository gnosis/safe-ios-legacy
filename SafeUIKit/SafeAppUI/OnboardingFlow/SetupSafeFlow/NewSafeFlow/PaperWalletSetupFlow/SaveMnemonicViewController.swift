//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import EthereumApplication

protocol SaveMnemonicDelegate: class {
    func didPressContinue()
}

final class SaveMnemonicViewController: UIViewController {

    private struct Strings {
        static let title = LocalizedString("new_safe.paper_wallet.title",
                                           comment: "Title for store paper wallet screen")
        static let save = LocalizedString("new_safe.paper_wallet.save", comment: "Save Button")
        static let description = LocalizedString("new_safe.paper_wallet.description",
                                                 comment: "Description for store paper wallet screen")
        static let `continue` = LocalizedString("new_safe.paper_wallet.continue",
                                                comment: "Continue button for store paper wallet screen")
    }

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var mnemonicCopyableLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!

    private(set) weak var delegate: SaveMnemonicDelegate?
    private var ethereumService: EthereumApplicationService {
        return ApplicationServiceRegistry.ethereumService
    }
    private(set) var account: EthereumApplicationService.ExternallyOwnedAccountData!

    static func create(delegate: SaveMnemonicDelegate) -> SaveMnemonicViewController {
        let controller = StoryboardScene.NewSafe.saveMnemonicViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    @IBAction func continuePressed(_ sender: Any) {
        delegate?.didPressContinue()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        account = ethereumService.generateExternallyOwnedAccount()
        guard !account.mnemonicWords.isEmpty else {
            mnemonicCopyableLabel.text = nil
            dismiss(animated: true)
            return
        }
        titleLabel.text = Strings.title
        mnemonicCopyableLabel.text = account.mnemonicWords.joined(separator: " ")
        mnemonicCopyableLabel.accessibilityIdentifier = "mnemonic"
        saveButton.setTitle(Strings.save, for: .normal)
        descriptionLabel.text = Strings.description
        descriptionLabel.accessibilityIdentifier = "description"
        continueButton.setTitle(Strings.continue, for: .normal)
    }

}
