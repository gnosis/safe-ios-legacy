//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import Common
import SafeUIKit
import MultisigWalletApplication

protocol EnterSeedViewControllerDelegate: class {

    func enterSeedViewControllerDidSubmit(_ vc: EnterSeedViewController)

}

class EnterSeedViewController: UIViewController, InputSeedViewDelegate {

    var recoveryModeEnabled = false

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subheaderLabel: UILabel!
    @IBOutlet weak var seedPhraseView: SeedPhraseView!
    @IBOutlet weak var bottomSeedView: BottomSeedView!

    /// If not nil, then event will be tracked. Otherwise, onboarding events are automatically tracked.
    var screenTrackingEvent: Trackable?
    weak var delegate: EnterSeedViewControllerDelegate?
    var account: ExternallyOwnedAccountData!
    var puzzle: SeedPhrasePuzzle!

    enum Strings {
        static let title = LocalizedString("ios_enterSeed_title", comment: "Title for confirm recovery screen.")
        static let header = LocalizedString("confirm_recovery_phrase_title", comment: "Do you have it?")
        static let subheader = LocalizedString("confirm_recovery_phrase_description", comment: "Tap the words")
        static let submit = LocalizedString("submit", comment: "Submit")
        static let tryAgain = LocalizedString("try_again", comment: "Try again")
    }

    static func create(delegate: EnterSeedViewControllerDelegate,
                       account: ExternallyOwnedAccountData,
                       isRecoveryMode: Bool = false) -> EnterSeedViewController {
        let controller = StoryboardScene.SeedPhrase.enterSeedViewController.instantiate()
        controller.delegate = delegate
        controller.account = account
        controller.recoveryModeEnabled = isRecoveryMode
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = recoveryModeEnabled ? nil : Strings.title
        view.backgroundColor = ColorName.white.color

        guard let words = account?.mnemonicWords, words.count > 1 else {
            ApplicationServiceRegistry.logger.error("Not enough words in mnemonic phrase")
            dismiss(animated: true)
            return
        }

        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        headerLabel.textColor = ColorName.darkBlue.color
        headerLabel.text = Strings.header

        subheaderLabel.textAlignment = .center
        subheaderLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        subheaderLabel.textColor = ColorName.darkGrey.color
        subheaderLabel.text = Strings.subheader

        bottomSeedView.inputSeedView.delegate = self

        puzzle = SeedPhrasePuzzle(words: account.mnemonicWords, puzzleWordCount: 4)
        reset()
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

    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         seedPhraseView.update()
         bottomSeedView.inputSeedView.update()
     }

    func reset() {
        puzzle.reset()
        seedPhraseView.words = puzzle.seedPhrase
        bottomSeedView.inputSeedView.words = puzzle.puzzleWords.shuffled().map {
            SeedWord(index: $0.index, value: $0.value, style: .normal)
        }
        bottomSeedView.submitButton.isEnabled = puzzle.isAllSlotsEntered
        bottomSeedView.submitTitle = Strings.submit
    }

    func inputSeedView(_ inputSeedView: InputSeedView, didEnterWord word: SeedWord) {
        puzzle.enter(word: word)
        seedPhraseView.words = puzzle.seedPhrase
        bottomSeedView.submitButton.isEnabled = puzzle.isAllSlotsEntered
    }

    @IBAction func didTapSubmit(_ sender: Any) {
        if bottomSeedView.submitTitle == Strings.tryAgain {
            reset()
            return
        }
        if puzzle.validate() {
            seedPhraseView.words = puzzle.seedPhrase
            confirmMnemonic()
            return
        }
        seedPhraseView.words = puzzle.seedPhrase
        bottomSeedView.submitTitle = Strings.tryAgain
    }

    private func confirmMnemonic() {
        if !recoveryModeEnabled && !hasAlreadySetOwnersFromMnemonic() {
            ApplicationServiceRegistry.walletService.addOwner(address: account.address, type: .paperWallet)
            let derivedAccount = ApplicationServiceRegistry.ethereumService
                .generateDerivedExternallyOwnedAccount(address: account.address)
            ApplicationServiceRegistry.walletService.addOwner(address: derivedAccount.address,
                                                              type: .paperWalletDerived)
        }
        delegate?.enterSeedViewControllerDidSubmit(self)
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

}


/// Bottom part of the view that groups word input and submit button
class BottomSeedView: UIView {

    @IBOutlet weak var inputSeedView: InputSeedView!
    @IBOutlet weak var submitButton: StandardButton!

    var submitTitle: String? {
        get {
            return submitButton?.title(for: .normal)
        }
        set {
            submitButton.setTitle(newValue, for: .normal)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        submitButton.style = .filled
        backgroundColor = ColorName.white.color
    }

}
