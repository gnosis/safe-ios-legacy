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
}

class OnboardingCreationFeeViewController: CardViewController {

    let feeRequestView = FeeRequestView()
    let addressDetailView = AddressDetailView()

    weak var delegate: OnboardingCreationFeeViewControllerDelegate?
    var creationProcessTracker = CreationProcessTracker()
    var isFinished: Bool = false

    enum Strings {

        static let title = LocalizedString("create_safe_title", comment: "Create Safe")
        static let sendOnlyTokenFormatTemplate = LocalizedString("please_send_x", comment: "Please send %")

        enum FeeRequest {
            static let subtitle = LocalizedString("safe_creation_fee", comment: "Safe creation fee")
            static let subtitleDetail = LocalizedString("network_fee_required", comment: "Network fee required")
        }

        enum Info {
            static let title = LocalizedString("what_is_safe_creation_fee", comment: "What is safe creation fee?")
            static let message = LocalizedString("network_fee_creation", comment: "Explanation")
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
        navigationItem.rightBarButtonItem = retryItem
        creationProcessTracker.retryItem = retryItem
        creationProcessTracker.viewController = self
        creationProcessTracker.onFailure = delegate?.deploymentDidFail

        setSubtitle(Strings.FeeRequest.subtitle)
        setSubtitleDetail(Strings.FeeRequest.subtitleDetail)

        feeRequestView.feeTextLabel.text = FeeRequestView.Strings.sendFeeRequest
        feeRequestView.balanceStackView.isHidden = true
        feeRequestView.feeAmountLabel.amount = TokenData.Ether.withBalance(nil)

        addressDetailView.shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)

        addressDetailView.headerLabel.isHidden = true
        addressDetailView.footnoteLabel.isHidden = true
        addressDetailView.isHidden = true

        footerButton.isHidden = true

        creationProcessTracker.start()
    }

    func setFootnoteTokenCode(_ code: String) {
        addressDetailView.footnoteLabel.text = String(format: Strings.sendOnlyTokenFormatTemplate, code)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingEvent.createSafe)
        trackEvent(OnboardingTrackingEvent.creationFee)
    }

    @objc func cancel() {
        let controller = AbortSafeCreationAlertController.create(abort: { [unowned self] in
            self.dismiss(animated: true, completion: nil)
            ApplicationServiceRegistry.walletService.abortDeployment()
            self.delegate?.deploymentDidCancel()
        }, continue: { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        })
        present(controller, animated: true, completion: nil)
    }


    @objc func share() {
        guard let address = ApplicationServiceRegistry.walletService.selectedWalletAddress else { return }
        let activityController = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        self.present(activityController, animated: true)
    }

    override func showNetworkFeeInfo() {
        // TODO: is it the one? NO! need to change texts!
        present(TransactionFeeAlertController.create(), animated: true, completion: nil)
    }

    func update() {
        let walletState = ApplicationServiceRegistry.walletService.walletState()!
        switch walletState {
        case .draft, .deploying:
            // started, but has nothing to show
            break
        case .waitingForFirstDeposit:
            let fee = ApplicationServiceRegistry.walletService.feePaymentTokenData
                .withBalance(ApplicationServiceRegistry.walletService.minimumDeploymentAmount!)
            feeRequestView.feeAmountLabel.amount = fee
            addressDetailView.address = ApplicationServiceRegistry.walletService.selectedWalletAddress
            setFootnoteTokenCode(fee.code)
            addressDetailView.footnoteLabel.isHidden = false
            addressDetailView.isHidden = false
        case .notEnoughFunds:
            let required = ApplicationServiceRegistry.walletService.feePaymentTokenData
                .withBalance(ApplicationServiceRegistry.walletService.minimumDeploymentAmount!)
            let received = ApplicationServiceRegistry.walletService
                .accountBalance(tokenID: BaseID(required.address)) ?? 0
            let remaining = required.balance == nil ? nil : (required.balance! - received)

            setSubtitle(Strings.Insufficient.subtitle, showError: true)
            setSubtitleDetail(Strings.Insufficient.subtitleDetail)

            feeRequestView.balanceStackView.isHidden = false
            feeRequestView.balanceLineAmountLabel.amount = required.withBalance(received)
            feeRequestView.totalLineAmountLabel.amount = required
            feeRequestView.feeAmountLabel.amount = required.withBalance(remaining)
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

}

extension OnboardingCreationFeeViewController: EventSubscriber {

    func notify() {
        DispatchQueue.main.async(execute: update)
    }


}
