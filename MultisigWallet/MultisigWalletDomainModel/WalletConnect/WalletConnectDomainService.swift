//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum WCError: Error {
    case wrongURLFormat
    case tryingToConnectExistingSessionURL
    case wrongSessionFormat
}

public protocol WalletConnectDomainService {

    func connect(url: String) throws
    func reconnect(session: WCSession) throws
    func disconnect(session: WCSession) throws
    func activeSessions() -> [WCSession]

}
