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
        var transactionType: TransactionType!
        switch type {
        case .connectAuthenticator: transactionType = .connectAuthenticator
        case .connectStatusKeycard: transactionType = .connectStatusKeycard
        default: preconditionFailure("inproper usage of ConnectTwoFAApplicationService")
        }
        domainService.updateTransaction(TransactionID(transactionID), with: transactionType)
    }

}
