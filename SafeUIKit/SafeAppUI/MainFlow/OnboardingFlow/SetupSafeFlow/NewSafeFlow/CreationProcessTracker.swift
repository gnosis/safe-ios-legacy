//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

/// Common functionality for starting safe deployment and handling errors during it.
class CreationProcessTracker {

    weak var retryItem: UIBarButtonItem!
    weak var viewController: (UIViewController & EventSubscriber)!

    var onFailure: (() -> Void)?

    @objc func start() {
        retryItem.isEnabled = false
        DispatchQueue.global().async { [unowned self] in
            ApplicationServiceRegistry
                .walletService.deployWallet(subscriber: self.viewController) { [unowned self] error in
                    DispatchQueue.main.async {
                        self.retryItem.isEnabled = true
                        self.handleError(error)
                    }
            }
        }
    }

    func handleError(_ error: Error) {
        let canRetry = isRetriableError(error)
        let controller = UIAlertController.operationFailed(message: error.localizedDescription) { [unowned self] in
            if !canRetry {
                self.viewController.dismiss(animated: true) {
                    self.onFailure?()
                }
            }
        }
        viewController.present(controller, animated: true, completion: nil)
    }

    func isRetriableError(_ error: Error) -> Bool {
        switch error {
        case let nsError as NSError where nsError.domain == NSURLErrorDomain:
            fallthrough
        case WalletApplicationServiceError.clientError,
             WalletApplicationServiceError.networkError,
             EthereumApplicationService.Error.clientError,
             EthereumApplicationService.Error.networkError:
            return true
        default:
            return false
        }
    }

}
