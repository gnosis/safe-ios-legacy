//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class RecoverReviewViewController: RBEReviewTransactionViewController {

    enum RecoveryStrings {
        static let title = LocalizedString("recover_safe_title", comment: "Title")
        static let header = LocalizedString("recover_existing_safe", comment: "Transaction name")
        static let detailNoAuthenticator = LocalizedString("existing_safe_recovered",
                                                           comment: "Recovery without authenticator.")
        static let detailWithAuthenticator = LocalizedString("existing_safe_recovered_authenticator",
                                                             comment: "Detail text for recovery with Authenticator.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = RecoveryStrings.title
    }

    override func createCells() {
        titleString = RecoveryStrings.header
        detailString = ApplicationServiceRegistry.recoveryService.isRecoveryTransactionConnectsAuthenticator(tx.id) ?
            RecoveryStrings.detailWithAuthenticator :
            RecoveryStrings.detailNoAuthenticator
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
