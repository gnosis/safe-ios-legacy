//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common
import BigInt
import SafariServices

class SafeCreationViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var retryButton: UIBarButtonItem!

    @IBOutlet weak var insufficientFundsErrorImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var requiredMinimumWrapperView: UIView!
    @IBOutlet weak var requiredMinimumHeaderLabel: UILabel!
    @IBOutlet weak var requiredMinimumAmountLabel: UILabel!
    @IBOutlet weak var requiredMinimumDescriptionLabel: UILabel!

    @IBOutlet weak var waitingForSafeWrapperView: UIView!
    @IBOutlet weak var waitingForSafeDescriptionLabel: UILabel!

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressStatusLabel: UILabel!

    @IBOutlet weak var safeAddressWrapperView: UIView!
    @IBOutlet weak var safeAddressDescription: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var safeAddressLabel: UILabel!
    @IBOutlet weak var qrCodeLabel: UILabel!
    @IBOutlet weak var qrCodeView: QRCodeView!

    @IBOutlet weak var etherscanWrapperView: UIView!
    @IBOutlet weak var etherscanLabel: UILabel!

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
        enum Status {
            static let generatingSafeAddress = LocalizedString("safe_creation.status.generating_safe_address",
                                                               comment: "Generation safe address.")
            static let awaitingDeposit = LocalizedString("safe_creation.status.awaiting_deposit",
                                                         comment: "Awaiting deposit label.")
            static let accountFunded = LocalizedString("safe_creation.status.account_funded",
                                                       comment: "Account received enough funds.")
            static let deploymentAccepted = LocalizedString("safe_creation.status.deployment_accepted",
                                                            comment: "Deployment accepted by blockchain.")
            static let error = LocalizedString("safe_creation.status.error",
                                               comment: "Error during safe creation. Retry later.")
        }
        enum SafeAddress {
            static let description = LocalizedString("safe_creation.safe_address.description",
                                                     comment: "Description how to share safe address.")
            static let address = LocalizedString("safe_creation.safe_address.address", comment: "Address label.")
            static let qrCode = LocalizedString("safe_creation.safe_address.qr_code", comment: "QR Code label.")
        }
        enum Etherscan {
            static let followProgress = LocalizedString("safe_creation.etherscan.follow_progress",
                                                        comment: "Follow its progress on Etherscan.io")
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
    internal var transactionHashIsKnownState: State!
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

    @IBAction func shareSafeAddress(_ sender: Any) {
        // TODO
    }

    @objc private func openProgressOnEtherscan() {
        let url = ApplicationServiceRegistry.walletService.walletCreationURL()
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        cancelButton.title = Strings.cancel
        retryButton.title = Strings.retry
        configureDescriptionTexts()
        configureSafeAddressTexts()
        configureEtherscanTexts()
        initStates()
        state = nilState
        deploy()
    }

    private func configureDescriptionTexts() {
        requiredMinimumHeaderLabel.text = Strings.FundSafe.requiredMinimumHeader
        requiredMinimumDescriptionLabel.text = Strings.FundSafe.requredMinimumDescription
        waitingForSafeDescriptionLabel.text = Strings.waitingForSafeDescription
        progressStatusLabel.accessibilityIdentifier = "safe_creation.status"
    }

    private func configureSafeAddressTexts() {
        addShadow(to: safeAddressWrapperView)
        safeAddressDescription.text = Strings.SafeAddress.description
        addressLabel.text = Strings.SafeAddress.address
        qrCodeLabel.text = Strings.SafeAddress.qrCode
        qrCodeView.padding = 12
        qrCodeView.layer.borderWidth = 1
        qrCodeView.layer.borderColor = UIColor.black.cgColor
        qrCodeView.layer.cornerRadius = 6
    }

    private func configureEtherscanTexts() {
        addShadow(to: etherscanWrapperView)
        let attrStr = NSMutableAttributedString(string: Strings.Etherscan.followProgress)
        let range = NSRange(location: 0, length: attrStr.length)
        attrStr.addAttribute(.foregroundColor, value: ColorName.aquaBlue.color, range: range)
        attrStr.addLinkIcon()
        etherscanLabel.attributedText = attrStr
        etherscanLabel.isUserInteractionEnabled = true
        etherscanLabel.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(openProgressOnEtherscan)))
    }

    private func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowOpacity = 0.2
    }

    private func initStates() {
        nilState = NilState()
        deployingState = DeployingState()
        notEnoughFundsState = NotEnoughFundsState()
        creationStartedState = CreationStartedState()
        transactionHashIsKnownState = TransactionHashIsKnownState()
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

        waitingForSafeWrapperView.isHidden = state.canCancel
        requiredMinimumWrapperView.isHidden = !state.canCancel

        insufficientFundsErrorImage.isHidden = !(state is NotEnoughFundsState)

        safeAddressWrapperView.isHidden = !(state is NotEnoughFundsState || state is CreationStartedState)
        safeAddressLabel.setEthereumAddress(state.addressText ?? "")
        qrCodeView.value = state.addressText

        etherscanWrapperView.isHidden = !(state is FinalizingDeploymentState || state is TransactionHashIsKnownState)
        etherscanLabel.isHidden = !(state is TransactionHashIsKnownState)

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
        case .transactionHashIsKnown: return transactionHashIsKnownState
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
        override var statusText: String? { return Strings.Status.generatingSafeAddress }
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
        override var progress: Double { return 0.8 }
    }

    class TransactionHashIsKnownState: State {
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