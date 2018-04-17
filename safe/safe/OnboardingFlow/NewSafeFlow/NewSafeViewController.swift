//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessApplication

protocol NewSafeDelegate: class {
    func didSelectPaperWalletSetup()
    func didSelectChromeExtensionSetup()
}

class NewSafeViewController: UIViewController {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var thisDeviceButton: BigButton!
    @IBOutlet weak var chromeExtensionButton: BigButton!
    @IBOutlet weak var paperWalletButton: BigButton!

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
        thisDeviceButton.setTitle(NSLocalizedString("onboarding.new_safe.this_device",
                                                    comment: "This device button"), for: .normal)
        paperWalletButton.setTitle(NSLocalizedString("onboarding.new_safe.paper_wallet",
                                                     comment: "Paper Wallet Button"), for: .normal)
        chromeExtensionButton.setTitle(NSLocalizedString("onboarding.new_safe.chrome_extension",
                                                         comment: "Chrome extension Button"), for: .normal)
        thisDeviceButton.isEnabled = false
        thisDeviceButton.checkmarkStatus = .selected
        paperWalletButton.checkmarkStatus = .normal
        chromeExtensionButton.checkmarkStatus = .normal
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func setupPaperWallet(_ sender: Any) {
        delegate?.didSelectPaperWalletSetup()
    }

    @IBAction func setupChromeExtension(_ sender: Any) {
        delegate?.didSelectChromeExtensionSetup()
    }

}
