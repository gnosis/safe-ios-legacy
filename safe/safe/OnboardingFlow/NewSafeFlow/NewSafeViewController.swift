//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication

protocol NewSafeDelegate: class {
    func didSelectPaperWalletSetup()
    func didSelectBrowserExtensionSetup()
    func didSelectNext()
}

class NewSafeViewController: UIViewController {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var thisDeviceButton: BigButton!
    @IBOutlet weak var browserExtensionButton: BigButton!
    @IBOutlet weak var paperWalletButton: BigButton!

    weak var delegate: NewSafeDelegate?
    private var draftSafe: DraftSafe?

    private var logger: Logger { return ApplicationServiceRegistry.logger }

    private struct Strings {
        static let title = NSLocalizedString("new_safe.title", comment: "Title for new safe screen")
        static let thisDevice = NSLocalizedString("new_safe.this_device", comment: "This device button")
        static let paperWallet = NSLocalizedString("new_safe.paper_wallet", comment: "Paper Wallet Button")
        static let browserExtension = NSLocalizedString("new_safe.browser_extension",
                                                        comment: "Browser extension Button")
    }

    static func create(draftSafe: DraftSafe?, delegate: NewSafeDelegate) -> NewSafeViewController {
        let controller = StoryboardScene.NewSafe.newSafeViewController.instantiate()
        controller.delegate = delegate
        controller.draftSafe = draftSafe
        return controller
    }

    @IBAction func navigateNext(_ sender: Any) {
        delegate?.didSelectNext()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard draftSafe != nil else {
            dismiss(animated: true)
            logger.error("DraftSafe is not provided in NewSafeViewController")
            return
        }
        titleLabel.text = Strings.title
        thisDeviceButton.setTitle(Strings.thisDevice, for: .normal)
        paperWalletButton.setTitle(Strings.paperWallet, for: .normal)
        browserExtensionButton.setTitle(Strings.browserExtension, for: .normal)
        thisDeviceButton.isEnabled = false
        thisDeviceButton.checkmarkStatus = .selected
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let draftSafe = draftSafe else { return }
        paperWalletButton.checkmarkStatus =
            draftSafe.confirmedAddresses.contains(.paperWallet) ? .selected : .normal
        browserExtensionButton.checkmarkStatus =
            draftSafe.confirmedAddresses.contains(.browserExtension) ? .selected : .normal
        nextButton.isEnabled = draftSafe.confirmedAddresses == .all
    }

    @IBAction func setupPaperWallet(_ sender: Any) {
        delegate?.didSelectPaperWalletSetup()
    }

    @IBAction func setupBrowserExtension(_ sender: Any) {
        delegate?.didSelectBrowserExtensionSetup()
    }

}
