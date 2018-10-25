//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common
import BigInt

class SafeCreationViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var retryButton: UIBarButtonItem!

    @IBOutlet weak var insufficientFundsErrorImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var requiredMinimumStackView: UIStackView!
    @IBOutlet weak var requiredMinimumHeaderLabel: UILabel!
    @IBOutlet weak var requiredMinimumAmountLabel: UILabel!
    @IBOutlet weak var requiredMinimumDescriptionLabel: UILabel!

    @IBOutlet weak var waitingForSafeStackView: UIStackView!
    @IBOutlet weak var waitingForSafeDescriptionLabel: UILabel!

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressStatusLabel: UILabel!

    weak var delegate: PendingSafeViewControllerDelegate?

    enum Strings {
        static let title = LocalizedString("safe_creation.title", comment: "Title for safe creation screen.")
        static let cancel = LocalizedString("safe_creation.cancel", comment: "Cancel safe creation button.")
        static let retry = LocalizedString("safe_creation.retry", comment: "Retry button title.")
        enum Header {
            static let firstDepositHeader = LocalizedString("safe_creation.first_deposit_header",
                                                            comment: "First deposit header for safe creation screen.")
            static let insufficientFundsHeader =
                LocalizedString("safe_creation.insufficient_funds_header",
                                comment: "Insufficient funds header for safe creation screen.")
            static let creatingSafeHeader =
                LocalizedString("safe_creation.creating_safe_header",
                                comment: "Creating safe header for safe creation screen.")

        }
        enum FundSafe {
            static let requiredMinimumHeader =
                LocalizedString("safe_creation.required_minimum_header",
                                comment: "Required minimum header for safe creation screen.")
            static let requredMinimumDescription =
                LocalizedString("safe_creation.required_minimum_description",
                                comment: "Required minimum description for safe creation screen.")
        }
        static let waitingForSafeDescription =
            LocalizedString("safe_creation.waiting_for_safe_description",
                            comment: "Waiting for safe description for safe creation screen.")

//        static let addressLabel = LocalizedString("safe_creation.address", comment: "Address label")
//        static let balanceLabel = LocalizedString("safe_creation.balanceLabel", comment: "Balance label")


        enum Status {
            static let awaitingDeposit = LocalizedString("safe_creation.status.awaiting_deposit",
                                                         comment: "Awaiting deposit label.")
            static let accountFunded = LocalizedString("safe_creation.status.account_funded",
                                                       comment: "Account received enough funds.")
            static let deploymentAccepted = LocalizedString("safe_creation.status.deployment_accepted",
                                                            comment: "Deployment accepted by blockchain.")
            static let error = LocalizedString("safe_creation.status.error",
                                               comment: "Error during safe creation. Retry later.")
        }

    }

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

    public static func create(delegate: PendingSafeViewControllerDelegate? = nil) -> SafeCreationViewController {
        let controller = StoryboardScene.NewSafe.safeCreationViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    @IBAction func retryDeployment(_ sender: Any) {
        deploy()
    }

    @IBAction func cancel(_ sender: Any) {
        delegate?.deploymentDidCancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        progressStatusLabel.accessibilityIdentifier = "safe_creation.status"
        configureTexts()
        initStates()
        state = nilState
        deploy()
    }

    private func configureTexts() {
        cancelButton.title = Strings.cancel
        retryButton.title = Strings.retry
        requiredMinimumHeaderLabel.text = Strings.FundSafe.requiredMinimumHeader
        requiredMinimumDescriptionLabel.text = Strings.FundSafe.requredMinimumDescription
        waitingForSafeDescriptionLabel.text = Strings.waitingForSafeDescription
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

    private func update() {
        guard isViewLoaded else { return }

        cancelButton.isEnabled = state.canCancel
        retryButton.isEnabled = state.canRetry

        headerLabel.text = state.headerText != nil ? state.headerText : headerLabel.text

        requiredMinimumAmountLabel.text = state.requiredAmountText
        requiredMinimumAmountLabel.textColor = state.requiredAmountTextColor

        progressStatusLabel.text = state.statusText
        progressStatusLabel.textColor = state.statusColor

        progressView.setProgress(Float(state.progress), animated: true)

        waitingForSafeStackView.isHidden = state.canCancel
        requiredMinimumStackView.isHidden = !state.canCancel

        insufficientFundsErrorImage.isHidden = !(state is NotEnoughFundsState)

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

    private func handleError(_ error: Error) {
        switch error {
        case let nsError as NSError where nsError.domain == NSURLErrorDomain:
            fallthrough
        case WalletApplicationServiceError.clientError, WalletApplicationServiceError.networkError,
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

extension SafeCreationViewController: EventSubscriber {

    // called during wallet deployment events
    public func notify() {
        let newState = state(from: ApplicationServiceRegistry.walletService.walletState()!)
        DispatchQueue.main.async {
            self.state = newState
        }
    }

}

// MARK: - States

extension SafeCreationViewController {

    func state(from walletState: WalletStateId) -> State {
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
        var headerText: String? { return nil }
        var statusText: String? { return nil }
        var statusColor: UIColor { return .black }
        var requiredAmountText: String? { return minimumAmount() }
        var requiredAmountTextColor: UIColor { return ColorName.battleshipGrey.color }
        var canCopyAddress: Bool { return false }
        var isFinalState: Bool { return false }
        var addressText: String? {
            guard let address = ApplicationServiceRegistry.walletService.selectedWalletAddress else { return nil }
            return address
        }
        var progress: Double { return 0 }

        private func minimumAmount() -> String? {
            let balance = ApplicationServiceRegistry.walletService.accountBalance(tokenID: ethID) ?? 0
            let payment = ApplicationServiceRegistry.walletService.minimumDeploymentAmount ?? 0
            let minimumAmount = payment - balance
            guard minimumAmount > 0 else { return nil }
            let formatter = TokenNumberFormatter.eth
            return formatter.string(from: minimumAmount)
        }
    }

    class NilState: State {
        override var canCancel: Bool { return true }
        override var addressText: String? { return nil }
    }

    // Usually not shown in UI because as soon as we know safe address
    // from the service, the state is already NotEnoughFunds
    class DeployingState: State {
        override var canCancel: Bool { return true }
        override var headerText: String? { return Strings.Header.firstDepositHeader }
        override var statusText: String? { return Strings.Status.awaitingDeposit }
        override var progress: Double { return 0.1 }
    }

    class NotEnoughFundsState: State {
        override var canCancel: Bool { return true }
        override var canCopyAddress: Bool { return true }
        override var headerText: String? { return Strings.Header.insufficientFundsHeader }
        override var statusText: String? { return Strings.Status.awaitingDeposit }
        override var requiredAmountTextColor: UIColor { return ColorName.tomato.color }
        override var progress: Double { return 0.3 }
    }

    class CreationStartedState: State {
        override var headerText: String? { return Strings.Header.creatingSafeHeader }
        override var statusText: String? { return Strings.Status.accountFunded }
        override var progress: Double { return 0.7 }
    }

    class FinalizingDeploymentState: State {
        override var headerText: String? { return Strings.Header.creatingSafeHeader }
        override var statusText: String? { return Strings.Status.deploymentAccepted }
        override var progress: Double { return 0.9 }
    }

    class ReadyToUseState: State {
        override var headerText: String? { return Strings.Header.creatingSafeHeader }
        override var statusText: String? { return Strings.Status.deploymentAccepted }
        override var progress: Double { return 1.0 }
        override var isFinalState: Bool { return true }
    }

    class ErrorState: State {
        override var statusText: String? { return Strings.Status.error }
        override var canRetry: Bool { return true }
        override var statusColor: UIColor { return ColorName.tomato.color }
    }

}
