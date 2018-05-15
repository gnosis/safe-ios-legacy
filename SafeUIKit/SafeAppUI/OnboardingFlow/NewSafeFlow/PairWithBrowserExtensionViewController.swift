//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import MultisigWalletApplication
import EthereumApplication

protocol PairWithBrowserDelegate: class {
    func didPair()
}

final class PairWithBrowserExtensionViewController: UIViewController {

    enum Strings {

        static let finish = LocalizedString("new_safe.extension.finish",
                                            comment: "Finish button title in extension setup screen")

    }

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var extensionAddressInput: QRCodeInput!
    @IBOutlet weak var finishButton: UIButton!

    private(set) weak var delegate: PairWithBrowserDelegate?
    private var logger: Logger {
        return ApplicationServiceRegistry.logger
    }
    private var walletService: WalletApplicationService {
        return ApplicationServiceRegistry.walletService
    }
    private var ethereumService: EthereumApplicationService {
        return ApplicationServiceRegistry.ethereumService
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
        finishButton.isEnabled = walletService.isOwnerExists(.browserExtension)
        finishButton.setTitle(Strings.finish, for: .normal)
    }

    @IBAction func finish(_ sender: Any) {
        guard let text = extensionAddressInput.text, !text.isEmpty else {
            logger.error("Wrong state in PairWithBrowserExtensionViewController.")
            return
        }
        walletService.addOwner(address: text, type: .browserExtension)
        delegate?.didPair()
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
        finishButton.isEnabled = true
    }

}
