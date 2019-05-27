//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

public protocol RecoveryInProgressViewControllerDelegate: class {

    func recoveryInProgressViewControllerDidFail()
    func recoveryInProgressViewControllerDidSuccess()
    func recoveryInProgressViewControllerWantsToOpenTransactionInExternalViewer(_ transactionID: String)

}

public class RecoveryInProgressViewController: UIViewController {

    private enum Strings {

        static let header = LocalizedString("recovering_safe", comment: "Header label for progress screen")
        static let progress = LocalizedString("transaction_submitted_safe_being_created",
                                              comment: "This can take a while...")
        static let externalLink = LocalizedString("ios_follow_progress", comment: "Follow its progress on Etherscan.io")

    }

    @IBOutlet weak var openExternalButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var headerLabel: UILabel!
    var headerStyle = HeaderStyle.contentHeader
    var isAnimatingProgress = false
    weak var delegate: RecoveryInProgressViewControllerDelegate?

    public static func create(delegate: RecoveryInProgressViewControllerDelegate?) -> RecoveryInProgressViewController {
        let controller = StoryboardScene.RecoverSafe.recoveryInProgressViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.attributedText = .header(from: Strings.header, style: headerStyle)
        progressLabel.text = Strings.progress
        openExternalButton.setTitle(Strings.externalLink, for: .normal)
        progressView.trackTintColor = ColorName.lightGreyBlue.color
        progressView.progressTintColor = ColorName.aquaBlue.color
        progressView.progress = 0
        resumeRecovery()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(RecoverSafeTrackingEvent.feePaid)
        guard !isAnimatingProgress else { return }
        isAnimatingProgress = true
        UIView.animate(withDuration: 120,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: { [unowned self] in
            self.progressView.setProgress(0.7, animated: true)
        }, completion: nil)
    }

    private func animateCopmletedProgress(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.7,
                       animations: { [unowned self] in
                        self.progressView.setProgress(1.0, animated: true)
            }, completion: { _ in
                completion()
        })
    }

    func resumeRecovery() {
        DispatchQueue.global().async {
            ApplicationServiceRegistry.recoveryService.resumeRecovery(subscriber: self) { [weak self] error in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.show(error: error)
                }
            }
        }
    }

    func success() {
        DispatchQueue.main.async { [unowned self] in
            self.animateCopmletedProgress {
                self.delegate?.recoveryInProgressViewControllerDidSuccess()
            }
        }
    }

    func show(error: Error) {
        let controller = UIAlertController.operationFailed(message: error.localizedDescription) {
            self.delegate?.recoveryInProgressViewControllerDidFail()
        }
        present(controller, animated: true)
    }

    @IBAction func openInExternalViewer(_ sender: Any) {
        if let transaction = ApplicationServiceRegistry.recoveryService.recoveryTransaction() {
            delegate?.recoveryInProgressViewControllerWantsToOpenTransactionInExternalViewer(transaction.id)
        }
    }

}

extension RecoveryInProgressViewController: EventSubscriber {

    public func notify() {
        success()
    }

}
