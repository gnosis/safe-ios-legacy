//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import SafariServices

protocol RecoverFeePaidViewControllerDelegate: class {
    func recoverFeePaidViewControllerOpenMenu()
    func recoverFeePaidViewControllerWantsToOpenTransactionInExternalViewer(_ transactionID: String)
    func recoverFeePaidViewControllerDidFail()
    func recoverFeePaidViewControllerDidSuccess()
}

class RecoverFeePaidViewController: FeePaidViewController {

    weak var delegate: RecoverFeePaidViewControllerDelegate?
    var retryItem: UIBarButtonItem!
    var recoveryProcessTracker = LongProcessTracker()

    static func create(delegate: RecoverFeePaidViewControllerDelegate) -> RecoverFeePaidViewController {
        let controller = RecoverFeePaidViewController(nibName: String(describing: FeePaidViewController.self),
                                                      bundle: Bundle(for: FeePaidViewController.self))
        controller.delegate = delegate
        return controller
    }

    enum Strings {
        static let header = LocalizedString("recovering_safe", comment: "Recovering safe")
        static let body = LocalizedString("transaction_submitted_safe_being_recovered",
                                          comment: "Transaction submitted")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(Strings.header)
        setBody(Strings.body)
        setImage(Asset.Onboarding.safeInprogress.image)
        button.isEnabled = false

        retryItem = UIBarButtonItem.refreshButton(target: self, action: #selector(retry))
        navigationItem.leftBarButtonItem = retryItem
        recoveryProcessTracker.delegate = self
        recoveryProcessTracker.retryItem = retryItem

        start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(RecoverSafeTrackingEvent.feePaid)
    }

    @objc func retry() {
        start()
    }

    func start() {
        recoveryProcessTracker.start()
    }

    // Called when wallet is recovered or transactoin hash is known
    func update() {
        progressAnimator.stop()
        if ApplicationServiceRegistry.walletService.hasReadyToUseWallet {
            progressAnimator.finish(duration: 0.7) { [weak self] in
                self?.delegate?.recoverFeePaidViewControllerDidSuccess()
            }
        } else {
            progressAnimator.resume(to: 0.97, duration: 100)
            button.isEnabled = true
        }
    }

    override func tapAction(_ sender: Any) {
        if let transaction = ApplicationServiceRegistry.recoveryService.recoveryTransaction() {
            delegate?.recoverFeePaidViewControllerWantsToOpenTransactionInExternalViewer(transaction.id)
        }
    }

    override func openMenu() {
        delegate?.recoverFeePaidViewControllerOpenMenu()
    }

}

extension RecoverFeePaidViewController: EventSubscriber {

    public func notify() {
        DispatchQueue.main.async(execute: update)
    }

}

extension RecoverFeePaidViewController: LongProcessTrackerDelegate {

    func startProcess(errorHandler: @escaping (Error) -> Void) {
        ApplicationServiceRegistry.recoveryService.resumeRecovery(subscriber: self, onError: errorHandler)
    }

    func processDidFail() {
        delegate?.recoverFeePaidViewControllerDidFail()
    }

}
