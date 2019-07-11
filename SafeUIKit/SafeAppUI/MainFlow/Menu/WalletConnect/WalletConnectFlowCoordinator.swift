//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import BigInt

final class WalletConnectFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        showSessionList()
    }

    func showSessionList() {
        push(WCSessionListTableViewController())
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
