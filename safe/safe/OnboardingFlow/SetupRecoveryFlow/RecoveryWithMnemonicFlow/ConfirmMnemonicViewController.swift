//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit

protocol ConfirmMnemonicDelegate: class {
    func didConfirm()
}

final class ConfirmMnemonicViewController: UIViewController {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var firstWordNumberLabel: UILabel!
    @IBOutlet weak var secondWordNumberLabel: UILabel!
    @IBOutlet weak var firstWordTextInput: TextInput!
    @IBOutlet weak var secondWordTextInput: TextInput!
    @IBOutlet weak var confirmButton: UIButton!

    weak var delegate: ConfirmMnemonicDelegate?

    @IBAction func confirm(_ sender: Any) {
    }

    static func create(delegate: ConfirmMnemonicDelegate) -> ConfirmMnemonicViewController {
        let controller = StoryboardScene.SetupRecovery.confirmMnemonicViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("recovery.confirm_mnemonic.title",
                                            comment: "Title for confirm mnemonic view controller")
        descriptionLabel.text = NSLocalizedString("recovery.confirm_mnemonic.description",
                                                  comment: "Description for confirm mnemonic view controller")
        confirmButton.setTitle(NSLocalizedString("recovery.confirm_mnemonic.confirm",
                                                 comment: "Confirm button"), for: .normal)        
    }

}
