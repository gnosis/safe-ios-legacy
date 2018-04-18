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
    private var draftSafe: DraftSafe?

    private var logger: Logger { return ApplicationServiceRegistry.service(for: Logger.self) }

    private struct Strings {
        static let title = NSLocalizedString("onboarding.new_safe.title", comment: "Title for new safe screen")
        static let thisDevice = NSLocalizedString("onboarding.new_safe.this_device", comment: "This device button")
        static let paperWallet = NSLocalizedString("onboarding.new_safe.paper_wallet", comment: "Paper Wallet Button")
        static let chromeExtension = NSLocalizedString("onboarding.new_safe.chrome_extension",
                                                       comment: "Chrome extension Button")
    }

    static func create(draftSafe: DraftSafe?, delegate: NewSafeDelegate) -> NewSafeViewController {
        let controller = StoryboardScene.NewSafe.newSafeViewController.instantiate()
        controller.delegate = delegate
        controller.draftSafe = draftSafe
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard draftSafe != nil else {
            dismiss(animated: true)
            logger.error("DraftSafe is not provided in NewSafeViewController",
                         error: nil,
                         file: #file,
                         line: #line,
                         function: #function)
            return
        }
        titleLabel.text = Strings.title
        thisDeviceButton.setTitle(Strings.thisDevice, for: .normal)
        paperWalletButton.setTitle(Strings.paperWallet, for: .normal)
        chromeExtensionButton.setTitle(Strings.chromeExtension, for: .normal)
        thisDeviceButton.isEnabled = false
        thisDeviceButton.checkmarkStatus = .selected
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let draftSafe = draftSafe else { return }
        paperWalletButton.checkmarkStatus =
            draftSafe.confirmedAddresses.contains(.paperWallet) ? .selected : .normal
        chromeExtensionButton.checkmarkStatus =
            draftSafe.confirmedAddresses.contains(.chromeExtension) ? .selected : .normal
    }

    @IBAction func setupPaperWallet(_ sender: Any) {
        delegate?.didSelectPaperWalletSetup()
    }

    @IBAction func setupChromeExtension(_ sender: Any) {
        delegate?.didSelectChromeExtensionSetup()
    }

}
