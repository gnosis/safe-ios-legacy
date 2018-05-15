//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol SetupSafeOptionsDelegate: class {
    func didSelectNewSafe()
}

class SetupSafeOptionsViewController: UIViewController {

    struct Strings {
        static let header = LocalizedString("onboarding.setup_safe.info", comment: "Set up safe options screen title")
        static let newSafe = LocalizedString("onboarding.setup_safe.new_safe", comment: "New safe button")
        static let restoreSafe = LocalizedString("onboarding.setup_safe.restore", comment: "Restore safe button")
    }

    @IBOutlet weak var headerLabel: H1Label!
    @IBOutlet weak var newSafeButton: BigButton!
    @IBOutlet weak var restoreSafeButton: BigButton!

    private weak var delegate: SetupSafeOptionsDelegate?

    @IBAction func createNewSafe(_ sender: Any) {
        delegate?.didSelectNewSafe()
    }

    static func create(delegate: SetupSafeOptionsDelegate) -> SetupSafeOptionsViewController {
        let vc = StoryboardScene.SetupSafe.setupSafeOptionsViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = Strings.header
        newSafeButton.setTitle(Strings.newSafe, for: .normal)
        restoreSafeButton.setTitle(Strings.restoreSafe, for: .normal)
    }

}
