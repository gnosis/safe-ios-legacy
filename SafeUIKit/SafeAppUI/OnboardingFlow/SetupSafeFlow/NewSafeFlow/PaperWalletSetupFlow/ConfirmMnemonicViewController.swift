//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import EthereumApplication
import MultisigWalletApplication

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

    private(set) weak var delegate: ConfirmMnemonicDelegate?
    var words: [String] { return account.mnemonicWords }
    private(set) var account: EthereumApplicationService.ExternallyOwnedAccount!
    private(set) var firstMnemonicWordToCheck = ""
    private(set) var secondMnemonicWordToCheck = ""

    static func create(delegate: ConfirmMnemonicDelegate,
                       account: EthereumApplicationService.ExternallyOwnedAccount) -> ConfirmMnemonicViewController {
        let controller = StoryboardScene.NewSafe.confirmMnemonicViewController.instantiate()
        controller.delegate = delegate
        controller.account = account
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let words = account?.mnemonicWords, words.count > 1 else {
            dismiss(animated: true)
            return
        }
        (firstMnemonicWordToCheck, secondMnemonicWordToCheck) = twoRandomWords()
        firstWordNumberLabel.text = "#\(words.index(of: firstMnemonicWordToCheck)! + 1)."
        firstWordNumberLabel.accessibilityIdentifier = "firstWordNumberLabel"
        secondWordNumberLabel.text = "#\(words.index(of: secondMnemonicWordToCheck)! + 1)."
        secondWordNumberLabel.accessibilityIdentifier = "secondWordNumberLabel"
        titleLabel.text = LocalizedString("recovery.confirm_mnemonic.title",
                                          comment: "Title for confirm mnemonic view controller")
        descriptionLabel.text = LocalizedString("recovery.confirm_mnemonic.description",
                                                comment: "Description for confirm mnemonic view controller")
        firstWordTextInput.delegate = self
        firstWordTextInput.accessibilityIdentifier = "firstInput"
        secondWordTextInput.delegate = self
        secondWordTextInput.accessibilityIdentifier = "secondInput"
        _ = firstWordTextInput.becomeFirstResponder()
    }

    private func twoRandomWords() -> (String, String) {
        var wordsCopy = account.mnemonicWords
        let firstIndex = Int(arc4random_uniform(UInt32(wordsCopy.count)))
        let firstWord = wordsCopy[firstIndex]
        wordsCopy.remove(at: firstIndex)
        let secondIndex = Int(arc4random_uniform(UInt32(wordsCopy.count)))
        let secondWord = wordsCopy[secondIndex]
        return (firstWord, secondWord)
    }

}

extension ConfirmMnemonicViewController: TextInputDelegate {

    func textInputDidReturn(_ textInput: TextInput) {
        if firstWordTextInput.text == firstMnemonicWordToCheck &&
            secondWordTextInput.text == secondMnemonicWordToCheck {
            do {
                try ApplicationServiceRegistry.walletService.addOwner(address: account.address, type: .paperWallet)
                delegate?.didConfirm()
            } catch {
                // TODO: handle error
            }
        } else if textInput == firstWordTextInput {
            _ = secondWordTextInput.becomeFirstResponder()
        }
    }

}
