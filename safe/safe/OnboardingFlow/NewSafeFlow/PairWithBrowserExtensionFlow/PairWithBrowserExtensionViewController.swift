//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit
import IdentityAccessApplication

protocol PairWithBrowserDelegate: class {
    func didPair(_ extensionAddress: String)
}

final class PairWithBrowserExtensionViewController: UIViewController {

    enum Strings {

        static let finish = NSLocalizedString("new_safe.extension.finish",
                                              comment: "Finish button title in extension setup screen")

    }

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var extensionAddressInput: QRCodeInput!
    @IBOutlet weak var finishButton: UIButton!

    private(set) weak var delegate: PairWithBrowserDelegate?
    private var initialExtensionAddress: String?
    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }
    private var logger: Logger { return ApplicationServiceRegistry.logger }

    private var scannerController: UIViewController?

    @IBAction func finish(_ sender: Any) {
        guard let text = extensionAddressInput.text, !text.isEmpty else {
            logger.error("Wrong state in PairWithBrowserExtensionViewController.")
            return
        }
        delegate?.didPair(text)
    }

    static func create(delegate: PairWithBrowserDelegate,
                       extensionAddress: String? = nil) -> PairWithBrowserExtensionViewController {
        let controller = StoryboardScene.NewSafe.pairWithBrowserExtensionViewController.instantiate()
        controller.delegate = delegate
        controller.initialExtensionAddress = extensionAddress
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        extensionAddressInput.text = initialExtensionAddress
        extensionAddressInput.editingMode = .scanOnly
        extensionAddressInput.qrCodeDelegate = self
        extensionAddressInput.qrCodeConverter = { [unowned self] code in
            return self.identityService.convertBrowserExtensionCodeIntoEthereumAddress(code)
        }
        finishButton.isEnabled = initialExtensionAddress != nil
        finishButton.setTitle(Strings.finish, for: .normal)
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
