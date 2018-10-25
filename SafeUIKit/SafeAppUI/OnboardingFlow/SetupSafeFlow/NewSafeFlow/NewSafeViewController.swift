//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import MultisigWalletApplication
import Common

protocol NewSafeDelegate: class {
    func didSelectPaperWalletSetup()
    func didSelectBrowserExtensionSetup()
    func didSelectNext()
}

class NewSafeViewController: UIViewController {

    enum Strings {
        static let title = LocalizedString("new_safe.title", comment: "Title for new safe screen")
        static let thisDevice = LocalizedString("new_safe.mobile_app", comment: "Mobile app button")
        static let recoveryPhrase = LocalizedString("new_safe.recovery_phrase", comment: "Recovery phrase button")
        static let browserExtension = LocalizedString("new_safe.browser_extension",
                                                      comment: "Browser extension button")
        static let next = LocalizedString("new_safe.next", comment: "Next button")
    }

    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var mobileAppButton: CheckmarkButton!
    @IBOutlet weak var recoveryPhraseButton: CheckmarkButton!
    @IBOutlet weak var browserExtensionButton: CheckmarkButton!

    weak var delegate: NewSafeDelegate?

    private var logger: Logger {
        return MultisigWalletApplication.ApplicationServiceRegistry.logger
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
        self.delegate?.didSelectNext()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        guard walletService.hasSelectedWallet else {
            dismiss(animated: true)
            logger.error("Draft wallet not found")
            return
        }
        nextButton.title = Strings.next
        configureThisDeviceButton()
        configureConnectBorwserExtensionButton()
        configureSetupRecoveryPhraseButton()
        configureWrapperView()
    }

    private func configureThisDeviceButton() {
        mobileAppButton.setTitle(Strings.thisDevice, for: .normal)
        mobileAppButton.isEnabled = false
        mobileAppButton.checkmarkStatus = .selected
    }

    private func configureConnectBorwserExtensionButton() {
        browserExtensionButton.setTitle(Strings.browserExtension, for: .normal)
    }

    private func configureSetupRecoveryPhraseButton() {
        recoveryPhraseButton.setTitle(Strings.recoveryPhrase, for: .normal)
    }

    private func configureWrapperView() {
        wrapperView.layer.shadowColor = UIColor.black.cgColor
        wrapperView.layer.shadowOffset = CGSize(width: 0, height: 2)
        wrapperView.layer.shadowOpacity = 0.4
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recoveryPhraseButton.checkmarkStatus = walletService.isOwnerExists(.paperWallet) ? .selected : .normal
        browserExtensionButton.checkmarkStatus = walletService.isOwnerExists(.browserExtension) ? .selected : .normal
        nextButton.isEnabled = walletService.isWalletDeployable
    }

    @IBAction func setupRecoveryPhrase(_ sender: Any) {
        delegate?.didSelectPaperWalletSetup()
    }

    @IBAction func setupBrowserExtension(_ sender: Any) {
        delegate?.didSelectBrowserExtensionSetup()
    }

}
