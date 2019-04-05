//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common
import BigInt
import SafariServices

public protocol SafeCreationViewControllerDelegate: class {
    func deploymentDidFail(_ localizedDescription: String)
    func deploymentDidSuccess()
    func deploymentDidCancel()
}

class SafeCreationViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var retryButton: UIBarButtonItem!

    @IBOutlet weak var insufficientFundsErrorImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var feeInfoButton: UIButton!

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
    @IBOutlet weak var safeAddressLabel: FullEthereumAddressLabel!
    @IBOutlet weak var qrCodeLabel: UILabel!
    @IBOutlet weak var qrCodeView: QRCodeView!

    @IBOutlet weak var etherscanWrapperView: UIView!
    @IBOutlet weak var etherscanLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIStackView!

    weak var delegate: SafeCreationViewControllerDelegate?

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
            state.didEnter()
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

    public static func create(delegate: SafeCreationViewControllerDelegate? = nil) -> SafeCreationViewController {
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
        guard let address = state.addressText else { return }
        let activityController = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        self.present(activityController, animated: true)
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
        navigationController?.navigationBar.shadowImage = UIImage()
        configureDescriptionTexts()
        configureSafeAddressTexts()
        configureEtherscanTexts()
        initStates()
        state = nilState
        deploy()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingEvent.createSafe)
        trackEvent(OnboardingTrackingEvent.creationFee)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = nil
    }

    private func configureDescriptionTexts() {
        requiredMinimumHeaderLabel.text = Strings.FundSafe.requiredMinimumHeader
        requiredMinimumDescriptionLabel.text = Strings.FundSafe.requredMinimumDescription
        waitingForSafeDescriptionLabel.text = Strings.waitingForSafeDescription
        progressStatusLabel.accessibilityIdentifier = "safe_creation.status"
        feeInfoButton.setTitleColor(ColorName.aquaBlue.color, for: .normal)
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
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
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

        insufficientFundsErrorImage.isHidden = !state.showsInsufficientFundsError

        safeAddressWrapperView.isHidden = !state.showsSafeAddress
        safeAddressLabel.address = state.addressText
        qrCodeView.value = state.addressText

        etherscanWrapperView.isHidden = !state.showsEtherScanBlock
        etherscanLabel.isHidden = !state.showsEtherScanLabel

        feeInfoButton.isHidden = !state.showsFeeExplanationButton

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

    @IBAction func showExplanation(_ sender: Any) {
        showTransactionFeeInfo()
    }

    // TODO: remove duplication
    @objc func showTransactionFeeInfo() {
        let alert = UIAlertController(title: LocalizedString("safe_creation.alert.title",
                                                             comment: "Transaction fee"),
                                      message: LocalizedString("safe_creation.alert.message",
                                                               comment: "Explanatory message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("safe_creation.alert.ok",
                                                             comment: "Ok"), style: .default))
        present(alert, animated: true)
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
        var showsInsufficientFundsError: Bool { return false }
        var showsSafeAddress: Bool { return false }
        var showsEtherScanBlock: Bool { return false }
        var showsEtherScanLabel: Bool { return false }
        var showsFeeExplanationButton: Bool { return false }

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

        func didEnter() {
            // to override
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
        override var showsInsufficientFundsError: Bool { return true }
        override var showsSafeAddress: Bool { return true }
        override var showsFeeExplanationButton: Bool { return true }
    }

    class CreationStartedState: State {
        override var headerText: String? { return Strings.Header.creatingSafeHeader }
        override var statusText: String? { return Strings.Status.accountFunded }
        override var progress: Double { return 0.7 }
        override var showsSafeAddress: Bool { return true }

        override func didEnter() {
            Tracker.shared.track(event: OnboardingEvent.safeFeePaid)
            Tracker.shared.track(event: OnboardingTrackingEvent.feePaid)
        }
    }

    class FinalizingDeploymentState: State {
        override var headerText: String? { return Strings.Header.creatingSafeHeader }
        override var statusText: String? { return Strings.Status.deploymentAccepted }
        override var progress: Double { return 0.8 }
        override var showsEtherScanBlock: Bool { return true }
    }

    class TransactionHashIsKnownState: State {
        override var headerText: String? { return Strings.Header.creatingSafeHeader }
        override var statusText: String? { return Strings.Status.deploymentAccepted }
        override var progress: Double { return 0.9 }
        override var showsEtherScanBlock: Bool { return true }
        override var showsEtherScanLabel: Bool { return true }
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
