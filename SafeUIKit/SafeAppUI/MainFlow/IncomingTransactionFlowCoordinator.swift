//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class IncomingTransactionFlowCoordinator: FlowCoordinator {

    let transactionID: String
    private let source: TransactionSource
    private let sourceMeta: Any?

    enum TransactionSource {
        case browserExtension
        case walletConnect
    }

    init(transactionID: String, source: TransactionSource, sourceMeta: Any?) {
        self.transactionID = transactionID
        self.source = source
        self.sourceMeta = sourceMeta
    }

    override func setUp() {
        super.setUp()
        switch source {
        case .browserExtension:
            let reviewVC = SendReviewViewController(transactionID: transactionID, delegate: self)
            push(reviewVC)
        case .walletConnect:
            let wcSessionData = sourceMeta as! WCSessionData
            let reviewVC = WCSendReviewViewController(transactionID: transactionID, delegate: self)
            reviewVC.wcSessionData = wcSessionData
            push(reviewVC)
        }
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
