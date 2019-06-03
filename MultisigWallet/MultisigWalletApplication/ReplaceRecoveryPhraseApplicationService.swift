//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class ReplaceRecoveryPhraseApplicationService: OwnerModificationApplicationService {

    public static func create() -> ReplaceRecoveryPhraseApplicationService {
        let service = ReplaceRecoveryPhraseApplicationService()
        service.domainService = DomainRegistry.replacePhraseService
        return service
    }

    public func update(transaction: String, newAddress: String) {
        domainService.update(transaction: TransactionID(transaction), newOwnerAddress: newAddress)
    }

}
