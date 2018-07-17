//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import IdentityAccessApplication
import MultisigWalletApplication
import MultisigWalletApplication
import Common

protocol PairWithBrowserDelegate: class {
    func didPair()
}

final class PairWithBrowserExtensionViewController: UIViewController {

    enum Strings {

        static let save = LocalizedString("new_safe.extension.save",
                                          comment: "Save button title in extension setup screen")
        static let update = LocalizedString("new_safe.extension.update",
                                            comment: "Update button title in extension setup screen")
        static let browserExtensionExpired = LocalizedString("new_safe.extension.expired",
                                                             comment: "Browser Extension Expired Message")
        static let networkError = LocalizedString("new_safe.extension.network_error", comment: "Network error message")
        static let invalidCode = LocalizedString("new_safe.extension.invalid_code_error",
                                                 comment: "Invalid extension code")

    }

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var extensionAddressInput: QRCodeInput!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private(set) weak var delegate: PairWithBrowserDelegate?
    private var logger: Logger {
        return MultisigWalletApplication.ApplicationServiceRegistry.logger
    }
    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }
    private var ethereumService: EthereumApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.ethereumService
    }

    private var scannerController: UIViewController?
    private var scannedCode: String?

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
        let buttonTitle = walletService.isOwnerExists(.browserExtension) ? Strings.update : Strings.save
        saveButton.setTitle(buttonTitle, for: .normal)
        saveButton.isEnabled = false
    }

    @IBAction func finish(_ sender: Any) {
        guard let text = extensionAddressInput.text, !text.isEmpty else {
            logger.error("Wrong state in PairWithBrowserExtensionViewController.")
            return
        }
        saveButton.isEnabled = false
        activityIndicator.startAnimating()
        DispatchQueue.global().async { [weak self] in
            self?.addBrowserExtensionOwner(address: text)
        }
    }

    private func addBrowserExtensionOwner(address: String) {
        do {
            try walletService.addBrowserExtensionOwner(address: address, browserExtensionCode: scannedCode!)
            DispatchQueue.main.async {
                self.delegate?.didPair()
            }
        } catch WalletApplicationService.Error.validationFailed {
            showError(message: Strings.invalidCode, log: "Invalid browser extension code")
        } catch WalletApplicationService.Error.networkError {
            showError(message: Strings.networkError, log: "Network Error in pairing")
        } catch WalletApplicationService.Error.exceededExpirationDate {
            showError(message: Strings.browserExtensionExpired, log: "Browser Extension code is expired")
        } catch let e {
            showFatalError(address, error: e)
        }
    }

    private func showFatalError(_ text: String, error: Error) {
        DispatchQueue.main.async {
            ErrorHandler.showFatalError(log: "Failed to add browser extension \(text)", error: error)
        }
    }

    private func showError(message: String, log: String) {
        DispatchQueue.main.async {
            self.saveButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            ErrorHandler.showError(message: message, log: log, error: nil)
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

    func didScanValidCode(_ code: String) {
        scannerController?.dismiss(animated: true)
        saveButton.isEnabled = true
        scannedCode = code
    }

}
