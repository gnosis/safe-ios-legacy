//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessApplication

protocol SaveMnemonicDelegate: class {
    func didPressContinue()
}

final class SaveMnemonicViewController: UIViewController {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var mnemonicCopyableLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!

    weak var delegate: SaveMnemonicDelegate?

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }

    static func create(delegate: SaveMnemonicDelegate) -> SaveMnemonicViewController {
        let controller = StoryboardScene.SetupRecovery.saveMnemonicViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    @IBAction func continuePressed(_ sender: Any) {
        delegate?.didPressContinue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let optionalEOA = try? identityService.getEOA(),
            let eoa = optionalEOA else {
            dismiss(animated: true)
            return
        }
        titleLabel.text = NSLocalizedString("recovery.save_mnemonic.title", comment: "Title for save mnemonic screen")
        mnemonicCopyableLabel.text = eoa.mnemonic.string()
        saveButton.setTitle(NSLocalizedString("recovery.save_mnemonic.save", comment: "Save Button"), for: .normal)
        descriptionLabel.text = NSLocalizedString("recovery.save_mnemonic.description",
                                                  comment: "Description for save mnemonic screen")
        continueButton.setTitle(NSLocalizedString("recovery.save_mnemonic.continue",
                                                  comment: "Continue button for save mnemonic screen"),
                                for: .normal)
    }

}
