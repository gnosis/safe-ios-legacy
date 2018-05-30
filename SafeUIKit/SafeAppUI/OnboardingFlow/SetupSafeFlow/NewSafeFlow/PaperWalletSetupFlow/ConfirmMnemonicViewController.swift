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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var firstWordNumberLabel: UILabel!
    @IBOutlet weak var secondWordNumberLabel: UILabel!
    @IBOutlet weak var firstWordTextInput: TextInput!
    @IBOutlet weak var secondWordTextInput: TextInput!
    @IBOutlet weak var confirmButton: UIButton!

    private var activeInput: TextInput?

    private(set) weak var delegate: ConfirmMnemonicDelegate?
    var words: [String] { return account.mnemonicWords }
    private(set) var account: ExternallyOwnedAccountData!
    private(set) var firstMnemonicWordToCheck = ""
    private(set) var secondMnemonicWordToCheck = ""

    static func create(delegate: ConfirmMnemonicDelegate,
                       account: ExternallyOwnedAccountData) -> ConfirmMnemonicViewController {
        let controller = StoryboardScene.NewSafe.confirmMnemonicViewController.instantiate()
        controller.delegate = delegate
        controller.account = account
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        firstWordTextInput.delegate = self
        firstWordTextInput.accessibilityIdentifier = "firstInput"
        secondWordTextInput.delegate = self
        secondWordTextInput.accessibilityIdentifier = "secondInput"
        _ = firstWordTextInput.becomeFirstResponder()
        registerForKeyboardNotifications()
    }

    private func configureAppearance() {
        guard let words = account?.mnemonicWords, words.count > 1 else {
            MultisigWalletApplication.ApplicationServiceRegistry.logger.error("Not enough words in mnemonic phrase")
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

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)),
                                               name: .UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(_:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }

    @objc private func keyboardWasShown(_ notification: Notification) {
        guard let info = (notification as NSNotification).userInfo,
            let kbSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size,
            let activeInput = activeInput else { return }
        let height = kbSize.height
        // swiftlint:disable:next legacy_constructor
        let contentInsets = UIEdgeInsetsMake(0, 0, height + 8, 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.scrollRectToVisible(activeInput.frame, animated: true)
    }

    @objc private func keyboardWillBeHidden(_ notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    @IBAction func confirm() {
        if !validate() { shakeErrors() }
    }

    private func validate() -> Bool {
        guard firstWordTextInput.text == firstMnemonicWordToCheck &&
            secondWordTextInput.text == secondMnemonicWordToCheck else { return false }
        do {
            try ApplicationServiceRegistry.walletService.addOwner(address: account.address, type: .paperWallet)
            delegate?.didConfirm()
        } catch let e {
            ErrorHandler.showFatalError(log: "Failed to add paper wallet owner \(account.address)", error: e)
        }
        return true
    }

    private func shakeErrors() {
        if firstWordTextInput.text != firstMnemonicWordToCheck { firstWordTextInput.shake() }
        if secondWordTextInput.text != secondMnemonicWordToCheck { secondWordTextInput.shake() }
    }

}

extension ConfirmMnemonicViewController: TextInputDelegate {

    func textInputDidBeginEditing(_ textInput: TextInput) {
        activeInput = textInput
    }

    func textInputDidEndEditing(_ textInput: TextInput) {
        activeInput = nil
    }

    func textInputDidReturn(_ textInput: TextInput) {
        if !validate() && textInput == firstWordTextInput {
            _ = secondWordTextInput.becomeFirstResponder()
        } else {
            shakeErrors()
        }
    }

}
