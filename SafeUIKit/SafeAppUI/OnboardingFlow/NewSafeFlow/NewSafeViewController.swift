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
        static let title = LocalizedString("new_safe.title", comment: "Title for new safe screen")
        static let thisDevice = LocalizedString("new_safe.this_device", comment: "This device button")
        static let paperWallet = LocalizedString("new_safe.paper_wallet", comment: "Paper Wallet Button")
        static let browserExtension = LocalizedString("new_safe.browser_extension",
                                                      comment: "Browser extension Button")
        static let next = LocalizedString("new_safe.create", comment: "Create button")
    }

    static func create(draftSafe: DraftSafe?, delegate: NewSafeDelegate) -> NewSafeViewController {
        let controller = StoryboardScene.NewSafe.newSafeViewController.instantiate()
        controller.delegate = delegate
        controller.draftSafe = draftSafe
        return controller
    }

    @IBAction func navigateNext(_ sender: Any) {
        // TODO: precondition: wallet with 3 owners set
        // postcondition: wallet deployment started, ethereum transaction created, safe address known
        // ethereumApplicationService.safeContractTransaction() -> tx, safeAddress(from: tx)
        // walletApplicationSerivce.startDeployment(safeAddress)
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
        nextButton.title = Strings.next
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: precondition: existing draft wallet (selected wallet)
        // its state is read into owners
        // a) primary b) browser extension c) paper wallet
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
