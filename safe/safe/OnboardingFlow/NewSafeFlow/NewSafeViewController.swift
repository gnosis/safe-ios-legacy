//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessApplication

protocol NewSafeDelegate: class {
    func didSelectPaperWalletSetup()
}

class NewSafeViewController: UIViewController {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var paperWalletButton: BigButton!
    @IBOutlet weak var chromeExtensionButton: BigButton!
    weak var delegate: NewSafeDelegate?

    static func create(delegate: NewSafeDelegate) -> NewSafeViewController {
        let controller = StoryboardScene.NewSafe.newSafeViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("onboarding.new_safe.title",
                                            comment: "Title for new safe screen")
        paperWalletButton.checkmarkStatus = .normal
        chromeExtensionButton.checkmarkStatus = .normal
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func setupPaperWallet(_ sender: Any) {
        delegate?.didSelectPaperWalletSetup()
    }

}
