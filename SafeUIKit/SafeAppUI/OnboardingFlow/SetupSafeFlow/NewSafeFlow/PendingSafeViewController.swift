//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

public protocol PendingSafeViewControllerDelegate: class {
    func deploymentDidFail()
    func deploymentDidSuccess()
    func deploymentDidCancel()
}

public class PendingSafeViewController: UIViewController {

    private struct Strings {

        static let title = LocalizedString("pending_safe.title", comment: "Title of pending safe screen")
        static let cancel = LocalizedString("pending_safe.cancel", comment: "Cancel safe creation button")
        static let info = LocalizedString("pending_safe.info", comment: "Info label about safe creation")
        static let addressLabel = LocalizedString("pending_safe.address", comment: "Address label")
        static let balanceLabel = LocalizedString("pending_safe.balanceLabel", comment: "Balance label")

        struct Status {

            static let started = LocalizedString("pending_safe.status.deployment_started",
                                                 comment: "Deployment started status")
            static let addressKnown = LocalizedString("pending_safe.status.address_known",
                                                      comment: "Address is known status")

            static let accountFunded = LocalizedString("pending_safe.status.account_funded",
                                                       comment: "Account received enough funds")
            static let notEnoughFundsFormat = LocalizedString("pending_safe.status.not_enough_funds",
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
    private var subscription: String?
    private var walletService: WalletApplicationService { return ApplicationServiceRegistry.walletService }
    private var uiUpdateQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.main
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }()

    public static func create(delegate: PendingSafeViewControllerDelegate? = nil) -> PendingSafeViewController {
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
        progressStatusLabel.accessibilityIdentifier = "pending_safe.status"
        progressView.progress = 0
        updateStatus()
        subscription = walletService.subscribe(updateStatus)
        startDeployment()
    }

    deinit {
        if let subscription = subscription {
            walletService.unsubscribe(subscription: subscription)
        }
    }

    private func startDeployment() {
        DispatchQueue.global().async {
            do {
                try ApplicationServiceRegistry.walletService.startDeployment()
            } catch let error {
                DispatchQueue.main.async {
                    ErrorHandler.showFatalError(log: "Failed to restart deployment", error: error)
                }
            }
        }
    }

    private func updateStatus() {
        let state = walletService.selectedWalletState
        let address = walletService.selectedWalletAddress
        let payment = walletService.minimumDeploymentAmount
        let balance = walletService.accountBalance(token: "ETH")
        uiUpdateQueue.addOperation { [unowned self] in
            self.updateAddressLabel(address: address, balance: balance)
            switch state {
            case .deploymentStarted:
                self.update(progress: 0.1, status: Strings.Status.started)
            case .addressKnown:
                self.update(progress: 0.2, status: Strings.Status.addressKnown)
            case .notEnoughFunds:
                self.update(progress: 0.2, status: self.notEnoughFundsStatus(payment: payment, balance: balance))
            case .accountFunded:
                self.update(progress: 0.5, status: Strings.Status.accountFunded)
            case .deploymentAcceptedByBlockchain:
                self.update(progress: 0.8, status: Strings.Status.deploymentAccepted)
            case .deploymentFailed:
                self.delegate?.deploymentDidFail()
            case .deploymentSuccess:
                self.update(progress: 1.0, status: Strings.Status.deploymentSuccess)
                self.delegate?.deploymentDidSuccess()
            default: break
            }
        }
    }

    private func updateAddressLabel(address: String?, balance: Int?) {
        var addressText = ""
        if let address = address {
            addressText += "\(Strings.addressLabel):\n\(address)"
        }
        if let balance = balance {
            addressText += "\n\(Strings.balanceLabel): \(balance) Wei"
        }
        self.safeAddressLabel.text = addressText
    }

    private func notEnoughFundsStatus(payment: Int!, balance: Int!) -> String {
        let requiredEth = "\(payment!) Wei"
        let balanceEth = "\(balance!) Wei"
        let status = String(format: Strings.Status.notEnoughFundsFormat, balanceEth, requiredEth)
        return status
    }

    private func update(progress: Float, status: String) {
        UIView.animate(withDuration: 0.2) {
            self.progressStatusLabel.text = status
        }
        progressView.setProgress(progress, animated: true)
    }

    @IBAction func cancel(_ sender: Any) {
        delegate?.deploymentDidCancel()
    }

}
