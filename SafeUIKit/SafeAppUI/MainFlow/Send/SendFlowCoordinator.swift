//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

// Implements navigation of the send funds flow:
// Send_Input -> Send_Review -> Send_Success
class SendFlowCoordinator: FlowCoordinator {

    var token: String!
    var address: String?

    convenience init() {
        self.init(rootViewController: nil)
    }

    override func setUp() {
        super.setUp()
        assert(token != nil, "Token must be set before entering SendFlowCoordinator")
        let transactionVC = SendInputViewController.create(tokenID: BaseID(token), address: address)
        transactionVC.delegate = self
        transactionVC.navigationItem.backBarButtonItem = .backButton()
        push(transactionVC) { [weak transactionVC] in
            transactionVC?.willBeRemoved()
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
        push(SuccessViewController.sendSuccess(token: controller.tx.amountTokenData) { [weak self] in
            self?.exitFlow()
        })
    }

}

extension SuccessViewController {

    static func sendSuccess(token: TokenData, action: @escaping () -> Void) -> SuccessViewController {
        return .congratulations(text: LocalizedString("transaction_has_been_submitted", comment: "Explanation text"),
                                image: Asset.congratulations.image,
                                tracking: SendTrackingEvent(.success, token: token.address, tokenName: token.code),
                                action: action)
    }

    static func congratulations(text: String,
                                image: UIImage,
                                tracking: Trackable,
                                action: @escaping () -> Void) -> SuccessViewController {
        return .create(title: LocalizedString("congratulations", comment: "Congratulations!"),
                detail: text,
                image: image,
                screenTrackingEvent: tracking,
                actionTitle: LocalizedString("continue_text", comment: "Continue"),
                action: action)
    }

}
