//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class ContractUpgradeApplicationService: OwnerModificationApplicationService {

    public static func create() -> ContractUpgradeApplicationService {
        let service = ContractUpgradeApplicationService()
        service.domainService = DomainRegistry.contractUpgradeService
        return service
    }

    public func update(transaction: String) {
        domainService.update(transaction: TransactionID(transaction), newOwnerAddress: "")
    }

}
