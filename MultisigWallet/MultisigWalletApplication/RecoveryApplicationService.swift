//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class RecoveryApplicationService {

    public init() {}

    public func createRecoverDraftWallet() {
        DomainRegistry.recoveryService.createRecoverDraftWallet()
    }

    public func prepareForRecovery() {
        DomainRegistry.recoveryService.prepareForRecovery()
    }

    public func validate(address: String, subscriber: EventSubscriber, onError errorHandler: @escaping (Error) -> Void) {
        DomainRegistry.errorStream.removeHandler(subscriber)
        DomainRegistry.errorStream.addHandler(subscriber, errorHandler)
        ApplicationServiceRegistry.eventRelay.unsubscribe(subscriber)
        ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: WalletAddressChanged.self)
        DomainRegistry.recoveryService.change(address: Address(address))
    }
    
}
