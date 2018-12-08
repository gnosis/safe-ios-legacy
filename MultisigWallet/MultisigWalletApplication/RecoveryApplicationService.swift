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
        withEnvironment(for: subscriber, errorHandler: errorHandler) {
            ApplicationServiceRegistry.eventRelay.subscribe(subscriber, for: WalletAddressChanged.self)
            DomainRegistry.recoveryService.change(address: Address(address))
        }
    }

    public func provide(recoveryPhrase: String,
                        subscriber: EventSubscriber,
                        onError errorHandler: @escaping (Error) -> Void) {
        withEnvironment(for: subscriber, errorHandler: errorHandler) {
            DomainRegistry.errorStream.post(RecoveryApplicationServiceError.invalidContractAddress)
        }
    }

    private func withEnvironment(for subscriber: EventSubscriber,
                                 errorHandler:  @escaping (Error) -> Void,
                                 closure: () -> Void) {
        setUpEnvironment(for: subscriber, errorHandler: errorHandler)
        closure()
        tearDownEnvironment(for: subscriber)
    }

    private func setUpEnvironment(for subscriber: EventSubscriber, errorHandler:  @escaping (Error) -> Void) {
        DomainRegistry.errorStream.removeHandler(self)
        DomainRegistry.errorStream.addHandler(self) { error in
            errorHandler(RecoveryApplicationService.applicationError(from: error))
        }
        ApplicationServiceRegistry.eventRelay.unsubscribe(subscriber)
    }

    private func tearDownEnvironment(for subscriber: EventSubscriber) {
        DomainRegistry.errorStream.removeHandler(self)
        ApplicationServiceRegistry.eventRelay.unsubscribe(subscriber)
    }

    private static func applicationError(from domainError: Error) -> Error {
        switch domainError {
        case RecoveryServiceError.invalidContractAddress:
            return RecoveryApplicationServiceError.invalidContractAddress
        default:
            return domainError
        }
    }

}
