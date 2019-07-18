//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import SafeUIKit
import MultisigWalletApplication
import MultisigWalletApplication

protocol ConfirmMnemonicDelegate: class {
    func confirmMnemonicViewControllerDidConfirm(_ vc: ConfirmMnemonicViewController)
}

final class ConfirmMnemonicViewController: UIViewController {

    enum Strings {
        static let title = LocalizedString("ios_enterSeed_title", comment: "Title for confirm recovery screen.")
        static let header = LocalizedString("ios_enterSeed_header", comment: "Title for confirm recovery screen.")
        static let next = LocalizedString("next", comment: "Next button for confirm recovery screen.")
        static let wordNumberPlaceholder = LocalizedString("ios_enterSeed_word", comment: "Word #%@")
    }

    var recoveryModeEnabled = false

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var firstWordTextInput: VerifiableInput!
    @IBOutlet weak var secondWordTextInput: VerifiableInput!

    /// If not nil, then event will be tracked. Otherwise, onboarding events are automatically tracked.
    var screenTrackingEvent: Trackable?

    private(set) weak var delegate: ConfirmMnemonicDelegate?
    var words: [String] { return account.mnemonicWords }
    private(set) var account: ExternallyOwnedAccountData!
    private(set) var firstMnemonicWordToCheck = ""
    private(set) var secondMnemonicWordToCheck = ""

    private(set) var keyboardBehavior: KeyboardAvoidingBehavior!

    var screenTitle: String? {
        return recoveryModeEnabled ? nil : Strings.title
    }

    static func create(delegate: ConfirmMnemonicDelegate,
                       account: ExternallyOwnedAccountData,
                       isRecoveryMode: Bool = false) -> ConfirmMnemonicViewController {
        let controller = StoryboardScene.CreateSafe.confirmMnemonicViewController.instantiate()
        controller.delegate = delegate
        controller.account = account
        controller.recoveryModeEnabled = isRecoveryMode
        return controller
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
        keyboardBehavior?.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = screenTrackingEvent {
            trackEvent(event)
        } else {
            trackEvent(OnboardingEvent.confirmRecovery)
            trackEvent(OnboardingTrackingEvent.enterSeed)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardBehavior?.stop()
    }

    private func configureInputs(words: [String]) {
        (firstMnemonicWordToCheck, secondMnemonicWordToCheck) = twoRandomWords()
        let firstWordIndex = String(words.firstIndex(of: firstMnemonicWordToCheck)! + 1)
        let secondWordIndex = String(words.firstIndex(of: secondMnemonicWordToCheck)! + 1)
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
    }

    private func configureTexts() {
        title = screenTitle
        headerLabel.text = Strings.header
        let nextButton = UIBarButtonItem(title: Strings.next, style: .plain, target: self, action: #selector(confirm))
        navigationItem.rightBarButtonItem = nextButton
    }

    private func configureKeyboardBehavior() {
        firstWordTextInput.avoidKeyboard()
        secondWordTextInput.avoidKeyboard()
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)
        keyboardBehavior.activeTextField = firstWordTextInput.textInput
    }

    func twoRandomWords() -> (String, String) {
        var wordsCopy = account.mnemonicWords
        let firstIndex = Int.random(in: wordsCopy.indices)
        let firstWord = wordsCopy[firstIndex]
        wordsCopy.remove(at: firstIndex)
        let secondIndex = Int.random(in: wordsCopy.indices)
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
        if !recoveryModeEnabled && !hasAlreadySetOwnersFromMnemonic() {
            ApplicationServiceRegistry.walletService.addOwner(address: account.address, type: .paperWallet)
            let derivedAccount = ApplicationServiceRegistry.ethereumService
                .generateDerivedExternallyOwnedAccount(address: account.address)
            ApplicationServiceRegistry.walletService.addOwner(address: derivedAccount.address,
                                                              type: .paperWalletDerived)
        }
        delegate?.confirmMnemonicViewControllerDidConfirm(self)
    }

    private func hasAlreadySetOwnersFromMnemonic() -> Bool {
        if let existingPaperWalletAddress = ApplicationServiceRegistry.walletService.ownerAddress(of: .paperWallet),
            let existingDerivedAddress = ApplicationServiceRegistry.walletService.ownerAddress(of: .paperWalletDerived),
            ApplicationServiceRegistry.ethereumService.findExternallyOwnedAccount(by: existingDerivedAddress) != nil,
            account.address == existingPaperWalletAddress {
            return true
        }
        return false
    }

    private func shakeErrors() {
        if firstWordTextInput.text != firstMnemonicWordToCheck { firstWordTextInput.shake() }
        if secondWordTextInput.text != secondMnemonicWordToCheck { secondWordTextInput.shake() }
    }

}

extension ConfirmMnemonicViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        if isValid() {
            confirmMnemonic()
        } else if verifiableInput == firstWordTextInput {
            keyboardBehavior.activeTextField = secondWordTextInput.textInput
        } else {
            shakeErrors()
        }
    }

}

extension TextInput: KeyboardAvoidingTargetProvider {

    func targetViewToAvoid() -> UIView? {
        return keyboardTargetView
    }

}

extension VerifiableInput {

    func avoidKeyboard() {
        textInput.keyboardTargetView = self
    }

}
