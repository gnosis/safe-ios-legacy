//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessApplication

protocol SaveMnemonicDelegate: class {
    func didPressContinue(mnemonicWords: [String])
}

final class SaveMnemonicViewController: UIViewController {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var mnemonicCopyableLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!

    private(set) weak var delegate: SaveMnemonicDelegate?
    private(set) var words = [String]()

    static func create(words: [String], delegate: SaveMnemonicDelegate) -> SaveMnemonicViewController {
        let controller = StoryboardScene.NewSafe.saveMnemonicViewController.instantiate()
        controller.words = words
        controller.delegate = delegate
        return controller
    }

    @IBAction func continuePressed(_ sender: Any) {
        delegate?.didPressContinue(mnemonicWords: words)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard !words.isEmpty else {
            dismiss(animated: true)
            return
        }
        titleLabel.text = NSLocalizedString("new_safe.paper_wallet.title",
                                            comment: "Title for store paper wallet screen")
        mnemonicCopyableLabel.text = words.joined(separator: " ")
        saveButton.setTitle(NSLocalizedString("new_safe.paper_wallet.save", comment: "Save Button"), for: .normal)
        descriptionLabel.text = NSLocalizedString("new_safe.paper_wallet.description",
                                                  comment: "Description for store paper wallet screen")
        continueButton.setTitle(NSLocalizedString("new_safe.paper_wallet.continue",
                                                  comment: "Continue button for store paper wallet screen"),
                                for: .normal)
    }

}
