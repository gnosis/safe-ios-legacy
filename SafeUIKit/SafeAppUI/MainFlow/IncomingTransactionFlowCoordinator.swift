//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class IncomingTransactionFlowCoordinator: FlowCoordinator {

    var transactionID: String!

    override func setUp() {
        super.setUp()
        assert(transactionID != nil, "TransactionID must be set before entering IncomingTransactionFlowCoordinator")
        let reviewVC = SendReviewViewController(transactionID: transactionID, delegate: self)
        push(reviewVC)
    }

}

extension IncomingTransactionFlowCoordinator: ReviewTransactionViewControllerDelegate {

    public func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                        completion: @escaping (Bool) -> Void) {
        TransactionSubmissionHandler().submitTransaction(from: self, completion: completion)
    }

    public func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        exitFlow()
    }

}
