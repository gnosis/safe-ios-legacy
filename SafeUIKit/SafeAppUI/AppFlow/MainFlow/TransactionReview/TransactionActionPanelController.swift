//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class TransactionActionPanelController {

    var status: TransactionData.Status { preconditionFailure("Not implemented") }

    static func create(from status: TransactionData.Status) -> TransactionActionPanelController {
        switch status {
        case .discarded: return TransactionDiscardedActionPanelController()
        case .failed: return TransactionFailedActionPanelController()
        case .pending: return TransactionPendingActionPanelController()
        case .readyToSubmit: return ReadyToSubmitActionPanelController()
        case .rejected: return TransactionRejectedActionPanelController()
        case .success: return TransactionSuccessActionPanelController()
        case .waitingForConfirmation: return WaitingForConfirmationActionPanelController()
        }
    }

    func changeActionPanel(in vc: TransactionReviewViewController) {
        vc.actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        vc.progressView.stopAnimating()
    }

    func requestSignaturesIfNeeded(_ vc: TransactionReviewViewController) {
        // no-op by default
    }

}

class WaitingForConfirmationActionPanelController: TransactionActionPanelController {

    override var status: TransactionData.Status { return .waitingForConfirmation }

    override func changeActionPanel(in vc: TransactionReviewViewController) {
        super.changeActionPanel(in: vc)
        vc.progressView.beginAnimating()
        vc.updateActionTitle(with: TransactionReviewViewController.Strings.Status.waiting)
        vc.actionButton.addTarget(vc, action: #selector(vc.requestSignatures), for: .touchUpInside)
    }

    override func requestSignaturesIfNeeded(_ vc: TransactionReviewViewController) {
        vc.requestSignatures()
    }

}

class TransactionRejectedActionPanelController: TransactionActionPanelController {

    override var status: TransactionData.Status { return .rejected }

    override func changeActionPanel(in vc: TransactionReviewViewController) {
        super.changeActionPanel(in: vc)
        vc.progressView.isError = true
        vc.updateActionTitle(with: TransactionReviewViewController.Strings.Status.rejected)
    }

}

class ReadyToSubmitActionPanelController: TransactionActionPanelController {

    override var status: TransactionData.Status { return .readyToSubmit }

    override func changeActionPanel(in vc: TransactionReviewViewController) {
        super.changeActionPanel(in: vc)
        vc.progressView.isError = false
        vc.progressView.isIndeterminate = false
        vc.progressView.progress = 1.0
        vc.updateActionTitle(with: TransactionReviewViewController.Strings.Status.readyToSubmit)
        vc.actionButton.addTarget(vc, action: #selector(vc.submit), for: .touchUpInside)
    }

    override func requestSignaturesIfNeeded(_ vc: TransactionReviewViewController) {
        vc.requestSignatures()
    }

}

class ReviewCompletedActionPanelController: TransactionActionPanelController {

    override var status: TransactionData.Status { preconditionFailure("Not implemented") }

    override func changeActionPanel(in vc: TransactionReviewViewController) {
        vc.delegate?.transactionReviewViewControllerDidFinish()
    }
}

class TransactionPendingActionPanelController: ReviewCompletedActionPanelController {
    override var status: TransactionData.Status { return .pending }
}

class TransactionFailedActionPanelController: ReviewCompletedActionPanelController {
    override var status: TransactionData.Status { return .failed }
}

class TransactionSuccessActionPanelController: ReviewCompletedActionPanelController {
    override var status: TransactionData.Status { return .success }
}

class TransactionDiscardedActionPanelController: ReviewCompletedActionPanelController {
    override var status: TransactionData.Status { return .discarded }
}
