//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import IdentityAccessApplication
import Common
import SafariServices

final class MainFlowCoordinator: FlowCoordinator {

    private let manageTokensFlowCoordinator = ManageTokensFlowCoordinator()
    private let connectExtensionFlowCoordinator = ConnectBrowserExtensionFlowCoordinator()

    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }

    private var authenticationService: AuthenticationApplicationService {
        return IdentityAccessApplication.ApplicationServiceRegistry.authenticationService
    }

    override func setUp() {
        super.setUp()
        let mainVC = MainViewController.create(delegate: self)
        mainVC.navigationItem.backBarButtonItem =
            UIBarButtonItem(title: LocalizedString("navigation.back", comment: "Back"),
                            style: .plain,
                            target: nil,
                            action: nil)
        push(mainVC)
    }

    func receive(message: [AnyHashable: Any]) {
        guard let transactionID = walletService.receive(message: message) else { return }
        if let vc = navigationController.topViewController as? ReviewTransactionViewController {
            let tx = ApplicationServiceRegistry.walletService.transactionData(transactionID)!
            vc.update(with: tx)
        } else {
            openTransactionReviewScreen(transactionID)
        }
    }

    private func openTransactionReviewScreen(_ id: String) {
        let reviewVC = ReviewTransactionViewController(transactionID: id, delegate: self)
        push(reviewVC)
    }

    private func openInSafari(_ url: URL) {
        let safari = SFSafariViewController(url: url)
        presentModally(safari)
    }

}

extension MainFlowCoordinator: MainViewControllerDelegate {

    func mainViewDidAppear() {
        UIApplication.shared.requestRemoteNotificationsRegistration()
        DispatchQueue.global().async {
            do {
                try self.walletService.auth()
            } catch let e {
                MultisigWalletApplication.ApplicationServiceRegistry.logger.error("Error in auth(): \(e)")
            }
        }
    }

    func createNewTransaction(token: String) {
        saveCheckpoint()
        let transactionVC = FundsTransferTransactionViewController.create(tokenID: BaseID(token))
        transactionVC.delegate = self
        push(transactionVC) {
            transactionVC.willBeRemoved()
        }
    }

    func openMenu() {
        let menuVC = MenuTableViewController.create()
        menuVC.delegate = self
        push(menuVC)
    }

    func manageTokens() {
        enter(flow: manageTokensFlowCoordinator)
    }

    func openAddressDetails() {
        let addressDetailsVC = SafeAddressViewController.create()
        push(addressDetailsVC)
    }

}

extension MainFlowCoordinator: TransactionsTableViewControllerDelegate {

    func didSelectTransaction(id: String) {
        let controller = TransactionDetailsViewController.create(transactionID: id)
        controller.delegate = self
        push(controller)
    }

}

extension MainFlowCoordinator: TransactionDetailsViewControllerDelegate {

    func showTransactionInExternalApp(from controller: TransactionDetailsViewController) {
        let transactionID = controller.transactionID!
        openInSafari(ApplicationServiceRegistry.walletService.transactionURL(transactionID))
    }

}

extension MainFlowCoordinator: FundsTransferTransactionViewControllerDelegate {

    func didCreateDraftTransaction(id: String) {
        openTransactionReviewScreen(id)
    }

}

extension MainFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func wantsToSubmitTransaction(_ completion: @escaping (Bool) -> Void) {
        if authenticationService.isUserAuthenticated {
            completion(true)
        } else {
            let unlockVC = UnlockViewController.create { [unowned self] success in
                self.dismissModal()
                completion(success)
            }
            unlockVC.showsCancelButton = true
            presentModally(unlockVC)
        }
    }

    func didFinishReview() {
        popToLastCheckpoint()
        showTransactionList()
    }

    private func showTransactionList() {
        if let mainVC = self.navigationController.topViewController as? MainViewController {
            mainVC.showTransactionList()
        }
    }

}

extension MainFlowCoordinator: MenuTableViewControllerDelegate {

    func didSelectManageTokens() {
        enter(flow: manageTokensFlowCoordinator)
    }

    func didSelectTermsOfUse() {
        openInSafari(ApplicationServiceRegistry.walletService.configuration.termsOfUseURL)
    }

    func didSelectPrivacyPolicy() {
        openInSafari(ApplicationServiceRegistry.walletService.configuration.privacyPolicyURL)
    }

    func didSelectConnectBrowserExtension() {
        enter(flow: connectExtensionFlowCoordinator)
    }

    func didSelectChangeBrowserExtension() {
        preconditionFailure("Not implemented")
    }

    func didSelectReplaceRecoveryPhrase() {
        let controller = ReplaceRecoveryPhraseViewController.create(delegate: self)
        push(controller) {
            controller.willBeDismissed()
        }
    }

}

extension MainFlowCoordinator: ReplaceRecoveryPhraseViewControllerDelegate {

    func replaceRecoveryPhraseViewControllerDidStart() {

    }

}
