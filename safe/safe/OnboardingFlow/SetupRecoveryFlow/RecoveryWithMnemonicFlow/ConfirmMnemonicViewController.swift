//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessDomainModel

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

    private(set) weak var delegate: ConfirmMnemonicDelegate?
    private(set) var mnemonic: Mnemonic!
    private(set) var firstMnemonicWordToCheck = ""
    private(set) var secondMnemonicWordToCheck = ""

    @IBAction func confirm(_ sender: Any) {
    }

    static func create(delegate: ConfirmMnemonicDelegate, mnemonic: Mnemonic) -> ConfirmMnemonicViewController {
        let controller = StoryboardScene.SetupRecovery.confirmMnemonicViewController.instantiate()
        controller.delegate = delegate
        controller.mnemonic = mnemonic
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mnemonic = mnemonic, mnemonic.words.count > 1 else {
            dismiss(animated: true)
            return
        }
        (firstMnemonicWordToCheck, secondMnemonicWordToCheck) = twoRandomWords()
        firstWordNumberLabel.text = "\(mnemonic.words.index(of: firstMnemonicWordToCheck)! + 1)."
        secondWordNumberLabel.text = "\(mnemonic.words.index(of: secondMnemonicWordToCheck)! + 1)."
        titleLabel.text = NSLocalizedString("recovery.confirm_mnemonic.title",
                                            comment: "Title for confirm mnemonic view controller")
        descriptionLabel.text = NSLocalizedString("recovery.confirm_mnemonic.description",
                                                  comment: "Description for confirm mnemonic view controller")
        confirmButton.setTitle(NSLocalizedString("recovery.confirm_mnemonic.confirm",
                                                 comment: "Confirm button"), for: .normal)
    }

    private func twoRandomWords() -> (String, String) {
        var words = mnemonic.words
        let firstIndex = Int(arc4random_uniform(UInt32(words.count)))
        let firstWord = words[firstIndex]
        words.remove(at: firstIndex)
        let secondIndex = Int(arc4random_uniform(UInt32(words.count)))
        let secondWord = words[secondIndex]
        return (firstWord, secondWord)
    }

}
