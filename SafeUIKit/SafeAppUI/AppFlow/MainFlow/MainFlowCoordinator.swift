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

    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }

    private var authenticationService: AuthenticationApplicationService {
        return IdentityAccessApplication.ApplicationServiceRegistry.authenticationService
    }

    override func setUp() {
        super.setUp()
        let mainVC = MainViewController.create(delegate: self)
        push(mainVC)
    }

    func receive(message: [AnyHashable: Any]) {
        guard let transactionID = walletService.receive(message: message) else { return }
        if let vc = navigationController.topViewController as? TransactionReviewViewController {
            vc.transactionID = transactionID
            vc.update()
        } else {
            openTransactionReviewScreen(transactionID)
        }
    }

    private func openTransactionReviewScreen(_ id: String) {
        let reviewVC = TransactionReviewViewController.create()
        reviewVC.transactionID = id
        reviewVC.delegate = self
        push(reviewVC)
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

    func createNewTransaction() {
        saveCheckpoint()
        let transactionVC = FundsTransferTransactionViewController.create(tokenID: ethID)
        transactionVC.delegate = self
        push(transactionVC) { transactionVC.willBeRemoved() }
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
        let url = ApplicationServiceRegistry.walletService.transactionURL(transactionID)
        let safari = SFSafariViewController(url: url)
        presentModally(safari)
    }

}

extension MainFlowCoordinator: FundsTransferTransactionViewControllerDelegate {

    func didCreateDraftTransaction(id: String) {
        openTransactionReviewScreen(id)
    }

}

extension MainFlowCoordinator: TransactionReviewViewControllerDelegate {

    func transactionReviewViewControllerDidFinish() {
        popToLastCheckpoint()
    }

    func transactionReviewViewControllerWantsToSubmitTransaction(completionHandler: @escaping (Bool) -> Void) {
        if authenticationService.isUserAuthenticated {
            completionHandler(true)
        } else {
            let unlockVC = UnlockViewController.create { [unowned self] success in
                self.dismissModal()
                completionHandler(success)
            }
            unlockVC.showsCancelButton = true
            presentModally(unlockVC)
        }
    }

}

extension MainFlowCoordinator: MenuTableViewControllerDelegate {

    func didSelectManageTokens() {
        enter(flow: manageTokensFlowCoordinator)
    }

}
