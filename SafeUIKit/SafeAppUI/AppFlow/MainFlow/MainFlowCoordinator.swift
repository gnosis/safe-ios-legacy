//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

final class MainFlowCoordinator: FlowCoordinator {

    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
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
                ApplicationServiceRegistry.logger.error("Error in auth(): \(e)")
            }
        }
    }

    func createNewTransaction() {
        let transactionVC = FundsTransferTransactionViewController.create()
        transactionVC.delegate = self
        push(transactionVC)
    }

}

extension MainFlowCoordinator: FundsTransferTransactionViewControllerDelegate {

    func didCreateDraftTransaction(id: String) {
        openTransactionReviewScreen(id)
    }

}
