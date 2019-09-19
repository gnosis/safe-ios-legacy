//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class ConnectTwoFAApplicationService: OwnerModificationApplicationService {

    public static func create() -> ConnectTwoFAApplicationService {
        let service = ConnectTwoFAApplicationService()
        service.domainService = DomainRegistry.connectTwoFAService
        return service
    }

    public func updateTransaction(_ transactionID: RBETransactionID, with type: TransactionData.TransactionType) {
        precondition(type.transactionType.isConnectTwoFA, "inproper usage of ConnectTwoFAApplicationService")
        domainService.updateTransaction(TransactionID(transactionID), with: type.transactionType)
    }

}
