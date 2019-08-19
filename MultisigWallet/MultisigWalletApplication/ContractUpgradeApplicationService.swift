//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class ContractUpgradeApplicationService: OwnerModificationApplicationService {

    private class ContractUpgradeSubscriber: EventSubscriber {

        var onReceive: (() -> Void)?

        func notify() {
            if let handler = onReceive {
                DispatchQueue.main.async(execute: handler)
            }
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

    public func isUpgradingTo_v1_0_0() -> Bool {
        let masterCopy = DomainRegistry.safeContractMetadataRepository.latestMasterCopyAddress
        let version = DomainRegistry.safeContractMetadataRepository.version(masterCopyAddress: masterCopy)
        return version == "1.0.0"
    }

}
