//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class InMemoryWCSessionRepository: WalletConnectSessionRepository {

    private var sessions = [WCSessionID: WCSession]()

    public init () {}

    public func save(_ item: WCSession) {
        sessions[item.id] = item
    }

    public func remove(id: WCSessionID) {
        sessions.removeValue(forKey: id)
    }

    public func find(id: WCSessionID) -> WCSession? {
        return sessions[id]
    }

    public func all() -> [WCSession] {
        let sessionList = Array(sessions.values)
        return sessionList.sorted { $0.dAppInfo.peerMeta.name < $1.dAppInfo.peerMeta.name }
    }

}
