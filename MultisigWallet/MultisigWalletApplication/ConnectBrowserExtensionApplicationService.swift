//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class ConnectBrowserExtensionApplicationService: OwnerModificationApplicationService {

    public static func create() -> ConnectBrowserExtensionApplicationService {
        let service = ConnectBrowserExtensionApplicationService()
        service.domainService = DomainRegistry.connectExtensionService
        return service
    }

    open override func connect(transaction: RBETransactionID, code: String) throws {
        try super.connect(transaction: transaction, code: code)
        let txID = TransactionID(transaction)
        let tx = DomainRegistry.transactionRepository.find(id: txID)!
        // needed for the wallet application service to process transaction
        tx.change(fee: nil).change(feeEstimate: nil)
        DomainRegistry.transactionRepository.save(tx)
    }

}
