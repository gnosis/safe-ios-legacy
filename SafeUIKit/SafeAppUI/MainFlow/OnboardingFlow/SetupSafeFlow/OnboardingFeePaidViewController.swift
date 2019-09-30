//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import SafariServices

protocol OnboardingFeePaidViewControllerDelegate: class {
    func onboardingFeePaidViewControllerDidFail(_ controller: OnboardingFeePaidViewController)
    func onboardingFeePaidViewControllerDidSuccess(_ controller: OnboardingFeePaidViewController)
    func onboardingFeePaidViewControllerOpenMenu(_ controller: OnboardingFeePaidViewController)
}

class OnboardingFeePaidViewController: FeePaidViewController {

    weak var delegate: OnboardingFeePaidViewControllerDelegate?
    var creationProcessTracker = LongProcessTracker()
    private(set) var walletID: String!

    static func create(delegate: OnboardingFeePaidViewControllerDelegate) -> OnboardingFeePaidViewController {
        let controller = OnboardingFeePaidViewController(nibName: String(describing: FeePaidViewController.self),
                                                         bundle: Bundle(for: FeePaidViewController.self))
        controller.delegate = delegate
        return controller
    }

    enum Strings {
        static let header = LocalizedString("creating_your_new_safe", comment: "Creating safe")
        static let body = LocalizedString("transaction_submitted_safe_being_created", comment: "Transaction submitted")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(Strings.header)
        setBody(Strings.body)
        setImage(Asset.Onboarding.creatingSafe.image)
        button.isEnabled = false
        walletID = ApplicationServiceRegistry.walletService.selectedWalletID()


        let retryItem = UIBarButtonItem.refreshButton(target: creationProcessTracker,
                                                      action: #selector(creationProcessTracker.start))
        navigationItem.leftBarButtonItem = retryItem
        creationProcessTracker.retryItem = retryItem
        creationProcessTracker.delegate = self
        creationProcessTracker.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingEvent.safeFeePaid)
        trackEvent(OnboardingTrackingEvent.feePaid)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ApplicationServiceRegistry.walletService.selectedWalletID() == walletID,
            ApplicationServiceRegistry.walletService.hasReadyToUseWallet {
            self.delegate?.onboardingFeePaidViewControllerDidSuccess(self)
        }
    }

    override func tapAction(_ sender: Any) {
        let url = ApplicationServiceRegistry.walletService.walletCreationURL()
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }

    override func openMenu() {
        delegate?.onboardingFeePaidViewControllerOpenMenu(self)
    }

    func update() {
        guard ApplicationServiceRegistry.walletService.selectedWalletID() == walletID,
            let walletState = ApplicationServiceRegistry.walletService.walletState() else { return }
        switch walletState {
        case .draft,
             .deploying,
             .waitingForFirstDeposit,
             .notEnoughFunds,
             .creationStarted,
             .finalizingDeployment:
            // nothing to do here, yet
            break
        case .transactionHashIsKnown:
            button.isEnabled = true
        case .readyToUse:
            button.isEnabled = true
            progressAnimator.finish(duration: 0.7) { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.onboardingFeePaidViewControllerDidSuccess(self)
            }
        }
    }

}

extension OnboardingFeePaidViewController: EventSubscriber {

    func notify() {
        DispatchQueue.main.async(execute: update)
    }

}

extension OnboardingFeePaidViewController: LongProcessTrackerDelegate {

    func startProcess(errorHandler: @escaping (Error) -> Void) {
        ApplicationServiceRegistry.walletService.deployWallet(subscriber: self, onError: errorHandler)
    }

    func processDidFail() {
        delegate?.onboardingFeePaidViewControllerDidFail(self)
    }

}
