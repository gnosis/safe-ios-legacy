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

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var extensionAddressInput: QRCodeInput!
    @IBOutlet weak var finishButton: UIButton!

    private(set) weak var delegate: PairWithBrowserDelegate?
    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }
    private var logger: Logger { return ApplicationServiceRegistry.logger }

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
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        extensionAddressInput.qrCodeDelegate = self
        extensionAddressInput.qrCodeConverter = { [unowned self] code in
            return self.identityService.convertBrowserExtensionCodeIntoEthereumAddress(code)
        }
        finishButton.isEnabled = false
    }

}

extension PairWithBrowserExtensionViewController: QRCodeInputDelegate {

    func presentScannerController(_ controller: UIViewController) {
        present(controller, animated: true)
    }

    func didScanValidCode() {
        finishButton.isEnabled = true
    }

}
