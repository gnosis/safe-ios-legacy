//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeUIKit
import Common
import MultisigWalletApplication

protocol OnboardingCreationFeeViewControllerDelegate: class {
    func deploymentDidCancel()
    func deploymentDidStart()
    func deploymentDidFail()
    func onboardingCreationFeeOpenMenu()
}

class OnboardingCreationFeeViewController: CardViewController {

    let feeRequestView = FeeRequestView()
    let addressDetailView = AddressDetailView()

    weak var delegate: OnboardingCreationFeeViewControllerDelegate?
    var creationProcessTracker = LongProcessTracker()
    var isFinished: Bool = false

    enum Strings {

        static let title = LocalizedString("create_safe_title", comment: "Create Safe")

        enum FeeRequest {
            static let subtitle = LocalizedString("safe_creation_fee", comment: "Safe creation fee")
            static let subtitleDetail = LocalizedString("network_fee_required", comment: "Network fee required")
        }

        enum Insufficient {
            static let subtitle = LocalizedString("insufficient_funds", comment: "Insufficient funds header.")
            static let subtitleDetail = LocalizedString("funds_did_not_meet_minimum", comment: "Explanation text.")
        }

    }

    static func create(delegate: OnboardingCreationFeeViewControllerDelegate) -> OnboardingCreationFeeViewController {
        let controller = OnboardingCreationFeeViewController(nibName: String(describing: CardViewController.self),
                                                             bundle: Bundle(for: CardViewController.self))
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        embed(view: feeRequestView, inCardSubview: cardHeaderView)
        embed(view: addressDetailView, inCardSubview: cardBodyView)

        navigationItem.title = Strings.title
        navigationItem.leftBarButtonItem = .cancelButton(target: self, action: #selector(cancel))

        let retryItem = UIBarButtonItem.refreshButton(target: creationProcessTracker,
                                                      action: #selector(creationProcessTracker.start))
        let menuItem = UIBarButtonItem.menuButton(target: self, action: #selector(openMenu))
        navigationItem.rightBarButtonItems = [menuItem, retryItem]
        creationProcessTracker.retryItem = retryItem
        creationProcessTracker.delegate = self

        setSubtitle(Strings.FeeRequest.subtitle)
        setSubtitleDetail(Strings.FeeRequest.subtitleDetail)

        feeRequestView.remainderTextLabel.text = FeeRequestView.Strings.sendFeeRequest
        feeRequestView.balanceStackView.isHidden = true
        feeRequestView.remainderAmountLabel.amount = TokenData.Ether.withBalance(nil)

        addressDetailView.shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)

        addressDetailView.headerLabel.isHidden = true
        addressDetailView.footnoteLabel.isHidden = true
        addressDetailView.isHidden = true

        footerButton.isHidden = true
        creationProcessTracker.start()
    }

    func setFootnoteTokenCode(_ code: String) {
        let template = LocalizedString("please_send_x", comment: "Please send %")
        addressDetailView.footnoteLabel.text = String(format: template, code)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingEvent.createSafe)
        trackEvent(OnboardingTrackingEvent.creationFee)
    }

    @objc func cancel() {
        let controller = UIAlertController.cancelSafeCreation(close: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }, continue: { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: nil)
            ApplicationServiceRegistry.walletService.abortDeployment()
            self.delegate?.deploymentDidCancel()
        })
        present(controller, animated: true, completion: nil)
    }

    // should stop updating while in background?

    @objc func share() {
        guard let address = ApplicationServiceRegistry.walletService.selectedWalletAddress else { return }
        let activityController = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        activityController.view.tintColor = ColorName.systemBlue.color
        self.present(activityController, animated: true)
    }

    @objc func openMenu(_ sender: UIBarButtonItem) {
        delegate?.onboardingCreationFeeOpenMenu()
    }

    override func showNetworkFeeInfo() {
        present(UIAlertController.creationFee(), animated: true, completion: nil)
    }

    func update() {
        guard let walletState = ApplicationServiceRegistry.walletService.walletState() else { return }
        switch walletState {
        case .draft, .deploying:
            // started, but has nothing to show
            break
        case .waitingForFirstDeposit:
            let fee = ApplicationServiceRegistry.walletService.feePaymentTokenData
                .withBalance(ApplicationServiceRegistry.walletService.minimumDeploymentAmount!)
            feeRequestView.remainderAmountLabel.amount = fee
            showAddressDetail(fee: fee)
        case .notEnoughFunds:
            let required = ApplicationServiceRegistry.walletService.feePaymentTokenData
                .withBalance(ApplicationServiceRegistry.walletService.minimumDeploymentAmount!)
            let received = ApplicationServiceRegistry.walletService
                .accountBalance(tokenID: BaseID(required.address)) ?? 0
            let remaining = required.balance == nil ? nil : max(required.balance! - received, 0)

            setSubtitle(Strings.Insufficient.subtitle, showError: true)
            setSubtitleDetail(Strings.Insufficient.subtitleDetail)

            feeRequestView.balanceStackView.isHidden = false
            feeRequestView.remainderTextLabel.text = FeeRequestView.Strings.sendRemainderRequest
            feeRequestView.amountReceivedAmountLabel.amount = required.withBalance(received)
            feeRequestView.amountNeededAmountLabel.amount = required
            feeRequestView.remainderAmountLabel.amount = required.withBalance(remaining)
            showAddressDetail(fee: required)
        case .creationStarted,
             .transactionHashIsKnown,
             .finalizingDeployment,
             .readyToUse:
            // has to exit from here because the screen is still visible for a while
            guard !isFinished else { return }
            isFinished = true
            // fee was enough, the creation started.
            // point of no return (or cancelling)
            navigationItem.leftBarButtonItem?.isEnabled = false
            delegate?.deploymentDidStart()
        }
    }

    private func showAddressDetail(fee: TokenData) {
        addressDetailView.address = ApplicationServiceRegistry.walletService.selectedWalletAddress
        setFootnoteTokenCode(fee.code)
        addressDetailView.footnoteLabel.isHidden = false
        addressDetailView.isHidden = false
    }

}

extension OnboardingCreationFeeViewController: EventSubscriber {

    func notify() {
        DispatchQueue.main.async(execute: update)
    }

}

extension OnboardingCreationFeeViewController: LongProcessTrackerDelegate {

    func startProcess(errorHandler: @escaping (Error) -> Void) {
        ApplicationServiceRegistry.walletService.deployWallet(subscriber: self, onError: errorHandler)
    }

    func processDidFail() {
        delegate?.deploymentDidFail()
    }

}

extension OnboardingCreationFeeViewController: InteractivePopGestureResponder {

    func interactivePopGestureShouldBegin() -> Bool {
        return false
    }

}
