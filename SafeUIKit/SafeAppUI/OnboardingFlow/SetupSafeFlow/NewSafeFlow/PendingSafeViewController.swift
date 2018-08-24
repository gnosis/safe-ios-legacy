//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common
import BigInt

public protocol PendingSafeViewControllerDelegate: class {
    func deploymentDidFail(_ localizedDescription: String)
    func deploymentDidSuccess()
    func deploymentDidCancel()
}

public class PendingSafeViewController: UIViewController, EventSubscriber {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var safeAddressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressStatusLabel: UILabel!
    @IBOutlet weak var copySafeAddressButton: UIButton!
    @IBOutlet var retryButton: UIBarButtonItem!

    weak var delegate: PendingSafeViewControllerDelegate?

    internal var state: State! {
        didSet {
            update()
        }
    }

    internal var nilState: State!
    internal var deployingState: State!
    internal var notEnoughFundsState: State!
    internal var creationStartedState: State!
    internal var finalizingDeploymentState: State!
    internal var readyToUseState: State!
    internal var errorState: State!

    public static func create(delegate: PendingSafeViewControllerDelegate? = nil) -> PendingSafeViewController {
        let controller = StoryboardScene.NewSafe.pendingSafeViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureLabels()
        initStates()
        state = nilState
        deploy()
    }

    private func configureLabels() {
        titleLabel.text = Strings.title
        cancelButton.title = Strings.cancel
        infoLabel.text = Strings.info
        retryButton.title = Strings.retry
        progressStatusLabel.accessibilityIdentifier = "pending_safe.status"
    }

    private func initStates() {
        nilState = NilState()
        deployingState = DeployingState()
        notEnoughFundsState = NotEnoughFundsState()
        creationStartedState = CreationStartedState()
        finalizingDeploymentState = FinalizingDeploymentState()
        readyToUseState = ReadyToUseState()
        errorState = ErrorState()
    }

    @IBAction func retryDeployment(_ sender: Any) {
        deploy()
    }

    @IBAction func cancel(_ sender: Any) {
        delegate?.deploymentDidCancel()
    }

    @IBAction func copySafeAddress(_ sender: Any) {
        UIPasteboard.general.string = ApplicationServiceRegistry.walletService.selectedWalletAddress!
    }

    private func update() {
        guard isViewLoaded else { return }
        cancelButton.isEnabled = state.canCancel
        retryButton.isEnabled = state.canRetry
        copySafeAddressButton.isHidden = !state.canCopyAddress
        safeAddressLabel.text = state.addressText
        progressStatusLabel.text = state.statusText
        progressView.setProgress(Float(state.progress), animated: true)
        if state.isFinalState {
            delegate?.deploymentDidSuccess()
        }
    }

    private func deploy() {
        DispatchQueue.global().async { [unowned self] in
            ApplicationServiceRegistry.walletService.deployWallet(subscriber: self) { error in
                DispatchQueue.main.async {
                    self.state = self.errorState
                    self.handleError(error)
                }
            }
        }
    }

    // called during wallet deployment events
    public func notify() {
        let newState = state(from: ApplicationServiceRegistry.walletService.walletState()!)
        DispatchQueue.main.async {
            self.state = newState
        }
    }

    private func handleError(_ error: Error) {
        switch error {
        case let nsError as NSError where nsError.domain == NSURLErrorDomain:
            fallthrough
        case WalletApplicationService.Error.clientError, WalletApplicationService.Error.networkError,
             EthereumApplicationService.Error.clientError, EthereumApplicationService.Error.networkError:
            notifyUser(error: error.localizedDescription)
        default:
            delegate?.deploymentDidFail(error.localizedDescription)
        }
    }

    private func notifyUser(error: String) {
        let controller = SafeCreationFailedAlertController.create(localizedErrorDescription: error) {
            // empty
        }
        present(controller, animated: true, completion: nil)
    }

}

extension PendingSafeViewController {

    struct Strings {

        static let title = LocalizedString("pending_safe.title", comment: "Title of pending safe screen")
        static let cancel = LocalizedString("pending_safe.cancel", comment: "Cancel safe creation button")
        static let info = LocalizedString("pending_safe.info", comment: "Info label about safe creation")
        static let addressLabel = LocalizedString("pending_safe.address", comment: "Address label")
        static let balanceLabel = LocalizedString("pending_safe.balanceLabel", comment: "Balance label")
        static let retry = LocalizedString("pending_safe.retry", comment: "Retry button title")

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
            static let error = LocalizedString("pending_safe.status.error",
                                               comment: "Error during safe creation. Retry later.")
        }

    }

}

extension PendingSafeViewController {

    func state(from walletState: WalletState1) -> State {
        switch walletState {
        case .deploying: return deployingState
        case .draft: return nilState
        case .notEnoughFunds: return notEnoughFundsState
        case .creationStarted: return creationStartedState
        case .finalizingDeployment: return finalizingDeploymentState
        case .readyToUse: return readyToUseState
        }
    }

    class State {
        var canCancel: Bool { return false }
        var canRetry: Bool { return false }
        var canCopyAddress: Bool { return false }
        var isFinalState: Bool { return false }
        var addressText: String? {
            guard let address = ApplicationServiceRegistry.walletService.selectedWalletAddress else { return nil }
            return "\(Strings.addressLabel): \(address)"
        }
        var statusText: String? { return nil }
        var progress: Double { return 0 }
    }

    class NilState: State {
        override var canCancel: Bool { return true }
        override var addressText: String? { return nil }
    }

    class DeployingState: State {
        override var statusText: String? { return Strings.Status.started }
        override var progress: Double { return 0.1 }
        override var canCancel: Bool { return true }
    }

    class NotEnoughFundsState: State {

        override var canCancel: Bool { return true }
        override var canCopyAddress: Bool { return true }

        override var statusText: String? {
            let balance = ApplicationServiceRegistry.walletService.accountBalance(tokenID: ethID)!
            let payment = ApplicationServiceRegistry.walletService.minimumDeploymentAmount!
            let formatter = TokenNumberFormatter.eth
            let formatString = Strings.Status.notEnoughFundsFormat
            return String(format: formatString, formatter.string(from: balance), formatter.string(from: payment))
        }

        override var progress: Double { return 0.3 }

    }

    class CreationStartedState: State {
        override var statusText: String? { return Strings.Status.accountFunded }
        override var progress: Double { return 0.7 }
    }

    class FinalizingDeploymentState: State {
        override var statusText: String? { return Strings.Status.deploymentAccepted }
        override var progress: Double { return 0.9 }
    }

    class ReadyToUseState: State {
        override var statusText: String? { return Strings.Status.deploymentSuccess }
        override var progress: Double { return 1.0 }
        override var isFinalState: Bool { return true }
    }

    class ErrorState: State {
        override var statusText: String? { return Strings.Status.error }
        override var canRetry: Bool { return true }
    }

}
