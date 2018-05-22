//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import MultisigWalletApplication

protocol NewSafeDelegate: class {
    func didSelectPaperWalletSetup()
    func didSelectBrowserExtensionSetup()
    func didSelectNext()
}

class NewSafeViewController: UIViewController {

    private struct Strings {

        static let title = LocalizedString("new_safe.title", comment: "Title for new safe screen")
        static let thisDevice = LocalizedString("new_safe.this_device", comment: "This device button")
        static let paperWallet = LocalizedString("new_safe.paper_wallet", comment: "Paper Wallet Button")
        static let browserExtension = LocalizedString("new_safe.browser_extension",
                                                      comment: "Browser extension Button")
        static let next = LocalizedString("new_safe.create", comment: "Create button")

    }

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var thisDeviceButton: BigButton!
    @IBOutlet weak var browserExtensionButton: BigButton!
    @IBOutlet weak var paperWalletButton: BigButton!

    weak var delegate: NewSafeDelegate?

    private var logger: Logger {
        return ApplicationServiceRegistry.logger
    }
    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }

    static func create(delegate: NewSafeDelegate) -> NewSafeViewController {
        let controller = StoryboardScene.NewSafe.newSafeViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    @IBAction func navigateNext(_ sender: Any) {
        do {
            try walletService.startDeployment()
            delegate?.didSelectNext()
        } catch {
            // TODO: log error
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard walletService.selectedWalletState != .none else {
            dismiss(animated: true)
            logger.error("Draft wallet not found")
            return
        }
        titleLabel.text = Strings.title
        thisDeviceButton.setTitle(Strings.thisDevice, for: .normal)
        thisDeviceButton.isEnabled = false
        thisDeviceButton.checkmarkStatus = .selected
        paperWalletButton.setTitle(Strings.paperWallet, for: .normal)
        browserExtensionButton.setTitle(Strings.browserExtension, for: .normal)
        nextButton.title = Strings.next
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        paperWalletButton.checkmarkStatus = walletService.isOwnerExists(.paperWallet) ? .selected : .normal
        browserExtensionButton.checkmarkStatus = walletService.isOwnerExists(.browserExtension) ? .selected : .normal
        nextButton.isEnabled = walletService.selectedWalletState == .readyToDeploy
    }

    @IBAction func setupPaperWallet(_ sender: Any) {
        delegate?.didSelectPaperWalletSetup()
    }

    @IBAction func setupBrowserExtension(_ sender: Any) {
        delegate?.didSelectBrowserExtensionSetup()
    }

}
