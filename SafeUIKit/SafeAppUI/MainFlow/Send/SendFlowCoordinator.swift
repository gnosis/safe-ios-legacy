//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

// Implements navigation of the send funds flow:
// Send_Input -> Send_Review -> Send_Success
class SendFlowCoordinator: FlowCoordinator {

    var token: String!

    convenience init() {
        self.init(rootViewController: nil)
    }

    override func setUp() {
        super.setUp()
        assert(token != nil, "Token must be set before entering SendFlowCoordinator")
        let transactionVC = SendInputViewController.create(tokenID: BaseID(token))
        transactionVC.delegate = self
        transactionVC.navigationItem.backBarButtonItem = .backButton()
        push(transactionVC) {
            transactionVC.willBeRemoved()
        }
    }

    func openTransactionReviewScreen(_ id: String) {
        let reviewVC = SendReviewViewController(transactionID: id, delegate: self)
        reviewVC.showsSubmitInNavigationBar = false
        push(reviewVC)
    }

}

extension SendFlowCoordinator: SendInputViewControllerDelegate {

    func didCreateDraftTransaction(id: String) {
        openTransactionReviewScreen(id)
    }

}

extension SendFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (Bool) -> Void) {
        TransactionSubmissionHandler().submitTransaction(from: self, completion: completion)
    }

    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        push(SuccessViewController.createSendSuccess(token: controller.tx.amountTokenData, action: exitFlow))
    }

}
