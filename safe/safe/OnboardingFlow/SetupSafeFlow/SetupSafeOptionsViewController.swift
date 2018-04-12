//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit

protocol SetupSafeOptionsDelegate: class {
    func didSelectNewSafe()
}

class SetupSafeOptionsViewController: UIViewController {

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
        headerLabel.text = NSLocalizedString("onboarding.setup_safe.info", comment: "Set up safe screen title")
    }

}
