//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class SessionUpdated: DomainEvent {}

public class WalletConnectApplicationService {

    private var service: WalletConnectDomainService {
        return DomainRegistry.walletConnectService
    }

    public init() {}

    public var isAvaliable: Bool {
        return ApplicationServiceRegistry.walletService.hasReadyToUseWallet
    }

    public func connect(url: String) throws {

    }

    public func disconnect(session: WCSession) {}

    public func sessions() -> [WCSession] { return [] }

    public func subscribeForSessionUpdates(_ subscriber: EventSubscriber) {}

}
