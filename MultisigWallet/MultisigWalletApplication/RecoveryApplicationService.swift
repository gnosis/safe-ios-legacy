//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public enum RecoveryApplicationServiceError: Error {
    case invalidContractAddress
}

public class RecoveryApplicationService {

    public init() {}

    public func createRecoverDraftWallet() {
        DomainRegistry.recoveryService.createRecoverDraftWallet()
    }

    public func prepareForRecovery() {
        DomainRegistry.recoveryService.prepareForRecovery()
    }

    public func validate(address: String,
                         subscriber: EventSubscriber,
                         onError errorHandler: @escaping (Error) -> Void) {
        DomainRegistry.errorStream.removeHandler(self)
        DomainRegistry.errorStream.addHandler(self) { error in
            switch error {
            case RecoveryServiceError.invalidContractAddress:
                errorHandler(RecoveryApplicationServiceError.invalidContractAddress)
            default:
                errorHandler(error)
            }
        }
        ApplicationServiceRegistry.eventRelay.unsubscribe(subscriber)
        ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: WalletAddressChanged.self)
        DomainRegistry.recoveryService.change(address: Address(address))
        DomainRegistry.errorStream.removeHandler(self)
        ApplicationServiceRegistry.eventRelay.unsubscribe(subscriber)
    }

}
