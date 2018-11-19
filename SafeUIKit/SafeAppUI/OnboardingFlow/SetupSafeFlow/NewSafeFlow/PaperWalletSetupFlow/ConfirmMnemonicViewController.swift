//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import MultisigWalletApplication

protocol ConfirmMnemonicDelegate: class {
    func didConfirm()
}

final class ConfirmMnemonicViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var firstWordTextInput: VerifiableInput!
    @IBOutlet weak var secondWordTextInput: VerifiableInput!

    private var activeInput: VerifiableInput?

    private(set) weak var delegate: ConfirmMnemonicDelegate?
    var words: [String] { return account.mnemonicWords }
    private(set) var account: ExternallyOwnedAccountData!
    private(set) var firstMnemonicWordToCheck = ""
    private(set) var secondMnemonicWordToCheck = ""

    private var keyboardBehavior: KeyboardAvoidingBehavior!

    static func create(delegate: ConfirmMnemonicDelegate,
                       account: ExternallyOwnedAccountData) -> ConfirmMnemonicViewController {
        let controller = StoryboardScene.NewSafe.confirmMnemonicViewController.instantiate()
        controller.delegate = delegate
        controller.account = account
        return controller
    }

    enum Strings {
        static let title = LocalizedString("new_safe.confirm_recovery.title",
                                           comment: "Title for confirm recovery screen.")
        static let header = LocalizedString("new_safe.confirm_recovery.header",
                                            comment: "Title for confirm recovery screen.")
        static let next = LocalizedString("new_safe.confirm_recovery.next",
                                          comment: "Next button for confirm recovery screen.")
        static let wordNumberPlaceholder = LocalizedString("new_safe.confirm_recovery.word_number",
                                                           comment: "Word #%@")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let words = account?.mnemonicWords, words.count > 1 else {
            MultisigWalletApplication.ApplicationServiceRegistry.logger.error("Not enough words in mnemonic phrase")
            dismiss(animated: true)
            return
        }
        configureInputs(words: words)
        configureTexts()
        configureKeyboardBehavior()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard keyboardBehavior != nil else { return }
        keyboardBehavior.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard keyboardBehavior != nil else { return }
        keyboardBehavior.stop()
    }

    private func configureInputs(words: [String]) {
        (firstMnemonicWordToCheck, secondMnemonicWordToCheck) = twoRandomWords()
        let firstWordIndex = String(words.index(of: firstMnemonicWordToCheck)! + 1)
        let secondWordIndex = String(words.index(of: secondMnemonicWordToCheck)! + 1)
        firstWordTextInput.textInput.placeholder = String(format: Strings.wordNumberPlaceholder, firstWordIndex)
        firstWordTextInput.delegate = self
        firstWordTextInput.accessibilityIdentifier = "firstInput"
        firstWordTextInput.textInput.style = .gray
        firstWordTextInput.trimsText = true
        secondWordTextInput.textInput.placeholder = String(format: Strings.wordNumberPlaceholder, secondWordIndex)
        secondWordTextInput.delegate = self
        secondWordTextInput.accessibilityIdentifier = "secondInput"
        secondWordTextInput.textInput.style = .gray
        secondWordTextInput.trimsText = true
         _ = firstWordTextInput.becomeFirstResponder()
    }

    private func configureTexts() {
        title = Strings.title
        headerLabel.text = Strings.header
        let nextButton = UIBarButtonItem(title: Strings.next, style: .plain, target: self, action: #selector(confirm))
        navigationItem.rightBarButtonItem = nextButton
    }

    private func configureKeyboardBehavior() {
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)
        keyboardBehavior.activeTextField = firstWordTextInput.textInput
        keyboardBehavior.useTextFieldSuperviewFrame = true
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

    @objc private func confirm() {
        if isValid() {
            confirmMnemonic()
        } else {
            shakeErrors()
        }
    }

    private func isValid() -> Bool {
        return firstWordTextInput.text == firstMnemonicWordToCheck &&
            secondWordTextInput.text == secondMnemonicWordToCheck
    }

    private func confirmMnemonic() {
        ApplicationServiceRegistry.walletService.addOwner(address: account.address, type: .paperWallet)
        let derivedAccount = ApplicationServiceRegistry.ethereumService
            .generateDerivedExternallyOwnedAccount(address: account.address)
        ApplicationServiceRegistry.walletService.addOwner(address: derivedAccount.address, type: .paperWalletDerived)
        delegate?.didConfirm()
    }

    private func shakeErrors() {
        if firstWordTextInput.text != firstMnemonicWordToCheck { firstWordTextInput.shake() }
        if secondWordTextInput.text != secondMnemonicWordToCheck { secondWordTextInput.shake() }
    }

}

extension ConfirmMnemonicViewController: VerifiableInputDelegate {

    func verifiableInputDidBeginEditing(_ verifiableInput: VerifiableInput) {
        activeInput = verifiableInput
    }

    func verifiableInputDidEndEditing(_ verifiableInput: VerifiableInput) {
        activeInput = nil
    }

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        if isValid() {
            confirmMnemonic()
        } else if verifiableInput == firstWordTextInput {
            _ = secondWordTextInput.becomeFirstResponder()
        } else {
            shakeErrors()
        }
    }

}
