//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class DisconnectTwoFAApplicationService: ReplaceTwoFAApplicationService {

    public static func createDisconnectService() -> DisconnectTwoFAApplicationService {
        let service = DisconnectTwoFAApplicationService()
        service.domainService = DomainRegistry.disconnectTwoFAService
        return service
    }

    open override func sign(transaction: RBETransactionID, withPhrase phrase: String) throws {
        DomainRegistry.disconnectTwoFAService.update(transaction: TransactionID(transaction))
        try super.sign(transaction: transaction, withPhrase: phrase)
    }

    public func updateTwoFATransactionType() -> TransactionData.TransactionType {
        let transactionType = domainService.updateTransactionType()
        switch transactionType {
        case .disconnectAuthenticator:
            return .disconnectAuthenticator
        case .disconnectStatusKeycard:
            return .disconnectStatusKeycard
        default:
            preconditionFailure("Inproper use of updateTwoFATransactionType() method")
        }
    }

}
