//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class RecoverReviewViewController: RBEReviewTransactionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedString("recover_safe_title", comment: "Title")
    }

    override func createCells() {
        titleString = LocalizedString("recover_existing_safe", comment: "Transaction name")
        detailString = LocalizedString("existing_safe_recovered", comment: "Transaction details")
        super.createCells()
    }

    override func fetchTransaction(_ id: String) -> TransactionData {
        return ApplicationServiceRegistry.recoveryService.transactionData(id)
    }

    override func feeCalculation() -> OwnerModificationFeeCalculation {
        let calculation = super.feeCalculation()
        calculation.border = nil
        return calculation
    }

    override func requestConfirmationsOnce() {
        /* empty */
    }

    override func submit() {
        delegate?.reviewTransactionViewControllerWantsToSubmitTransaction(self) { [unowned self] success in
            if success {
                self.delegate?.reviewTransactionViewControllerDidFinishReview(self)
            }
        }
    }

}
