//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import MultisigWalletApplication
import EthereumApplication
import Common

protocol PairWithBrowserDelegate: class {
    func didPair()
}

final class PairWithBrowserExtensionViewController: UIViewController {

    enum Strings {

        static let save = LocalizedString("new_safe.extension.save",
                                          comment: "Save button title in extension setup screen")

    }

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var extensionAddressInput: QRCodeInput!
    @IBOutlet weak var saveButton: UIButton!

    private(set) weak var delegate: PairWithBrowserDelegate?
    private var logger: Logger {
        return MultisigWalletApplication.ApplicationServiceRegistry.logger
    }
    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }
    private var ethereumService: EthereumApplicationService {
        return EthereumApplication.ApplicationServiceRegistry.ethereumService
    }

    private var scannerController: UIViewController?

    static func create(delegate: PairWithBrowserDelegate) -> PairWithBrowserExtensionViewController {
        let controller = StoryboardScene.NewSafe.pairWithBrowserExtensionViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        extensionAddressInput.text = walletService.ownerAddress(of: .browserExtension)
        extensionAddressInput.editingMode = .scanOnly
        extensionAddressInput.qrCodeDelegate = self
        extensionAddressInput.qrCodeConverter = ethereumService.address(browserExtensionCode:)
        saveButton.isEnabled = walletService.isOwnerExists(.browserExtension)
        saveButton.setTitle(Strings.save, for: .normal)
    }

    @IBAction func finish(_ sender: Any) {
        guard let text = extensionAddressInput.text, !text.isEmpty else {
            logger.error("Wrong state in PairWithBrowserExtensionViewController.")
            return
        }
        do {
            try walletService.addOwner(address: text, type: .browserExtension)
            delegate?.didPair()
        } catch let e {
            ErrorHandler.showFatalError(log: "Failed to add browser extension \(text)", error: e)
        }
    }

}

extension PairWithBrowserExtensionViewController: QRCodeInputDelegate {

    func presentScannerController(_ controller: UIViewController) {
        scannerController = controller
        present(controller, animated: true)
    }

    func presentCameraRequiredAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }

    func didScanValidCode() {
        scannerController?.dismiss(animated: true)
        saveButton.isEnabled = true
    }

}
