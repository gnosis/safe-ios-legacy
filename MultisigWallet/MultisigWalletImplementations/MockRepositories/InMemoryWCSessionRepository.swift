//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class InMemoryWCSessionRepository: WCSessionRepository {

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

    public func all(withClientMetaOnly: Bool) -> [WCSession] {
        let sessionList = Array(sessions.values)
        if withClientMetaOnly {
            return sessionList.filter { $0.peerMeta != nil }.sorted { $0.peerMeta!.name < $1.peerMeta!.name }
        } else {
            return sessionList
        }
    }

}
