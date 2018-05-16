//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

public protocol PendingSafeViewControllerDelegate: class {
    func deploymentDidFail()
    func deploymentDidSuccess()
}

public class PendingSafeViewController: UIViewController {

    private struct Strings {
        static let title = LocalizedString("pending_safe.title", comment: "Title of pending safe screen")
        static let cancel = LocalizedString("pending_safe.cancel", comment: "Cancel safe creation button")
        static let info = LocalizedString("pending_safe.info", comment: "Info label about safe creation")

        struct Status {
            static let started = LocalizedString("pending_safe.status.deployment_started",
                                                 comment: "Deployment started status")
            static let addressKnown = LocalizedString("pending_safe.status.address_known",
                                                      comment: "Address is known status")
            static let accountFunded = LocalizedString("pending_safe.status.account_funded",
                                                       comment: "Account received enough funds")
            static let notEnoughFunds = LocalizedString("pending_safe.status.not_enough_funds",
                                                        comment: "Not enough funds in account")
            static let deploymentAccepted = LocalizedString("pending_safe.status.deployment_accepted",
                                                            comment: "Deployment accepted by blockchain")
            static let deploymentSuccess = LocalizedString("pending_safe.status.deployment_success",
                                                           comment: "Deployment succeeded")
        }
    }

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var safeAddressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressStatusLabel: UILabel!
    weak var delegate: PendingSafeViewControllerDelegate?

    public static func create(delegate: PendingSafeViewControllerDelegate) -> PendingSafeViewController {
        let controller = StoryboardScene.NewSafe.pendingSafeViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = Strings.title
        cancelButton.title = Strings.cancel
        infoLabel.text = Strings.info
        safeAddressLabel.text = nil
        progressStatusLabel.text = nil
        progressView.progress = 0
        updateStatus()
    }

    private func updateStatus() {
        switch ApplicationServiceRegistry.walletService.selectedWalletState {
        case .deploymentStarted:
            update(progress: 0.1, status: Strings.Status.started)
        case .addressKnown:
            update(progress: 0.2, status: Strings.Status.addressKnown)
        case .accountFunded:
            update(progress: 0.5, status: Strings.Status.accountFunded)
        case .notEnoughFunds:
            update(progress: 0.5, status: Strings.Status.notEnoughFunds)
        case .deploymentAcceptedByBlockchain:
            update(progress: 0.8, status: Strings.Status.deploymentAccepted)
        case .deploymentFailed:
            delegate?.deploymentDidFail()
        case .deploymentSuccess:
            update(progress: 1.0, status: Strings.Status.deploymentSuccess)
            delegate?.deploymentDidSuccess()
        default: break
        }
    }

    private func update(progress: Float, status: String) {
        progressStatusLabel.text = status
        progressView.progress = progress
    }

    @IBAction func cancel(_ sender: Any) {
    }

}
