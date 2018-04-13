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

    private(set) weak var delegate: ConfirmMnemonicDelegate?
    private(set) var words: [String]!
    private(set) var firstMnemonicWordToCheck = ""
    private(set) var secondMnemonicWordToCheck = ""

    static func create(delegate: ConfirmMnemonicDelegate, words: [String]) -> ConfirmMnemonicViewController {
        let controller = StoryboardScene.SetupRecovery.confirmMnemonicViewController.instantiate()
        controller.delegate = delegate
        controller.words = words
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let words = words, words.count > 1 else {
            dismiss(animated: true)
            return
        }
        (firstMnemonicWordToCheck, secondMnemonicWordToCheck) = twoRandomWords()
        firstWordNumberLabel.text = "#\(words.index(of: firstMnemonicWordToCheck)! + 1)."
        secondWordNumberLabel.text = "#\(words.index(of: secondMnemonicWordToCheck)! + 1)."
        titleLabel.text = NSLocalizedString("recovery.confirm_mnemonic.title",
                                            comment: "Title for confirm mnemonic view controller")
        descriptionLabel.text = NSLocalizedString("recovery.confirm_mnemonic.description",
                                                  comment: "Description for confirm mnemonic view controller")
        firstWordTextInput.delegate = self
        secondWordTextInput.delegate = self
        _ = firstWordTextInput.becomeFirstResponder()
    }

    private func twoRandomWords() -> (String, String) {
        var wordsCopy = words!
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
            delegate?.didConfirm()
        } else if textInput == firstWordTextInput {
            _ = secondWordTextInput.becomeFirstResponder()
        }
    }

}
