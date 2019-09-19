//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class ReplaceTwoFAApplicationService: OwnerModificationApplicationService {

    public static func create() -> ReplaceTwoFAApplicationService {
        let service = ReplaceTwoFAApplicationService()
        service.domainService = DomainRegistry.replace2FAService
        return service
    }

    open func sign(transaction: RBETransactionID, withPhrase phrase: String) throws {
        let txID = TransactionID(transaction)
        domainService.stepBackToDraft(txID)
        _ = try domainService.estimateNetworkFee(for: txID)
        try domainService.sign(transactionID: txID, with: phrase)
    }

    public func updateTransaction(_ transactionID: RBETransactionID, with type: TransactionData.TransactionType) {
        precondition(type.transactionType.isReplaceTwoFA, "improper usage of ReplaceTwoFAApplicationService")
        domainService.updateTransaction(TransactionID(transactionID), with: type.transactionType)
    }

}
