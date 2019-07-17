//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import BigInt

final class WalletConnectFlowCoordinator: FlowCoordinator {

    weak var sessionListController: WCSessionListTableViewController?
    weak var onboardingController: WCOnboardingViewController?

    override func setUp() {
        super.setUp()
        if ApplicationServiceRegistry.walletConnectService.isOnboardingDone() {
            showSessionList()
        } else {
            showOnboarding()
        }
    }

    func showOnboarding() {
        let vc = WCOnboardingViewController.create(next: { [weak self] in
            self?.onboardingController?.transitionToNextPage()
        }, finish: { [weak self] in
            self?.finishOnboarding()
        })
        push(vc)
        onboardingController = vc
    }

    func finishOnboarding() {
        ApplicationServiceRegistry.walletConnectService.markOnboardingDone()
        showSessionList()
        if let vc = self.onboardingController {
            self.removeViewControllerFromStack(vc)
        }
        // waiting for showSessionList animation completion
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            self?.showScan()
        }
    }

    func showScan() {
        self.sessionListController?.scan()
    }

    func showSessionList() {
        let vc = WCSessionListTableViewController()
        push(vc)
        sessionListController = vc
    }

    func showSendReview() {
        // TODO: This is a tmp stub. Replace with real implementation.
        let transactionID = ApplicationServiceRegistry.walletService.createNewDraftTransaction()
        ApplicationServiceRegistry.walletService
            .updateTransaction(transactionID,
                               amount: BigInt(100_000),
                               token: "0x0000000000000000000000000000000000000000",
                               recipient: "0x728cafe9fB8CC2218Fb12a9A2D9335193caa07e0")
        push(WCSendReviewViewController(transactionID: transactionID, delegate: self))
    }

}

extension WalletConnectFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (Bool) -> Void) {
        TransactionSubmissionHandler().submitTransaction(from: self, completion: completion)
    }

    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        exitFlow()
    }

}

fileprivate extension WCOnboardingViewController {

    static func create(next: @escaping () -> Void, finish: @escaping () -> Void) -> WCOnboardingViewController {
        let nextActionTitle = LocalizedString("next", comment: "Next")
        return .create(steps: [
            .init(image: Asset.WalletConnect._1.image,
                  title: LocalizedString("welcome_to_walletconnect", comment: "Onboarding 1 title"),
                  description: LocalizedString("walletconnect_is", comment: "Onboarding 1 description"),
                  actionTitle: nextActionTitle,
                  trackingEvent: WCTrackingEvent.onboarding1,
                  action: next),
            .init(image: Asset.WalletConnect._2.image,
                  title: LocalizedString("how_does_it_work", comment: "Onboarding 2 title"),
                  description: LocalizedString("you_can_manage_connections", comment: "Onboarding 2 description"),
                  actionTitle: nextActionTitle,
                  trackingEvent: WCTrackingEvent.onboarding2,
                  action: next),
            .init(image: Asset.WalletConnect._3.image,
                  title: LocalizedString("lets_get_started", comment: "Onboarding 3 title"),
                  description: LocalizedString("to_connect_to_dapp", comment: "Onboarding 3 description"),
                  actionTitle: LocalizedString("get_started", comment: "Start button title"),
                  trackingEvent: WCTrackingEvent.onboarding3,
                  action: finish)
        ])
    }

}
