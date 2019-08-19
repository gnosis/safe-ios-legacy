//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class ContractUpgradeApplicationService: OwnerModificationApplicationService {

    private class ContractUpgradeSubscriber: EventSubscriber {

        var onReceive: (() -> Void)?

        func notify() {
            onReceive?()
        }

    }

    private var subscriber = ContractUpgradeSubscriber()

    public static func create() -> ContractUpgradeApplicationService {
        let service = ContractUpgradeApplicationService()
        service.domainService = DomainRegistry.contractUpgradeService
        return service
    }

    public func update(transaction: String) {
        domainService.update(transaction: TransactionID(transaction), newOwnerAddress: "")
    }

    public func subscribeForContractUpgrade(_ handler: @escaping () -> Void) {
        subscriber.onReceive = handler
        ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: ContractUpgraded.self)
    }

}
