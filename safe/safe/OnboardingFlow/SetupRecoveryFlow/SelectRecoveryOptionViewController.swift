//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

protocol SetupRecoveryOptionDelegate: class {
    func didSelectMnemonicRecovery()
}

class SelectRecoveryOptionViewController: UIViewController {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var mnemonicRecoveryButton: BigButton!
    @IBOutlet weak var otherRecoveryOptionTemporaryButton: BigButton!

    @IBAction func setupMnemonicRecovery(_ sender: Any) {
        delegate?.didSelectMnemonicRecovery()
    }

    weak var delegate: SetupRecoveryOptionDelegate?

    static func create(delegate: SetupRecoveryOptionDelegate) -> SelectRecoveryOptionViewController {
        let controller = StoryboardScene.SetupRecovery.selectRecoveryOptionViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("onboarding.recovery_options.title",
                                            comment: "Title for selecting recovery option screen")
    }

}
