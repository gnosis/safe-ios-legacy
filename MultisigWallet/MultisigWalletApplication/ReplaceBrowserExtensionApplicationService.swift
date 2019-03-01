//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class ReplaceBrowserExtensionApplicationService: OwnerModificationApplicationService {

    public static func create() -> ReplaceBrowserExtensionApplicationService {
        let service = ReplaceBrowserExtensionApplicationService()
        service.domainService = DomainRegistry.replaceExtensionService
        return service
    }

    open func sign(transaction: RBETransactionID, withPhrase phrase: String) throws {
        let txID = TransactionID(transaction)
        domainService.stepBackToDraft(txID)
        _ = try domainService.estimateNetworkFee(for: txID)
        try domainService.sign(transactionID: txID, with: phrase)
    }

}
