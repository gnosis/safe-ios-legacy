//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

protocol LongProcessTrackerDelegate: class {
    func startProcess(errorHandler: @escaping (Error) -> Void)
    func processDidFail()
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

/// Common functionality for starting safe deployment or recovery and handling errors during it.
class LongProcessTracker {

    weak var retryItem: UIBarButtonItem!
    weak var delegate: LongProcessTrackerDelegate?

    @objc func start() {
        retryItem.isEnabled = false
        DispatchQueue.global().async { [weak self] in
            // swiftlint:disable:next trailing_closure
            self?.delegate?.startProcess(errorHandler: { error in
                DispatchQueue.main.async {
                    guard let `self` = self else { return }
                    self.retryItem.isEnabled = true
                    self.handleError(error)
                }
            })
        }
    }

    func handleError(_ error: Error) {
        let canRetry = isRetriableError(error)
        retryItem.isEnabled = canRetry
        let controller = UIAlertController.operationFailed(message: error.localizedDescription) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.dismiss(animated: true, completion: nil)
            if !canRetry {
                self.delegate?.processDidFail()
            }
        }
        delegate?.present(controller, animated: true, completion: nil)
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
