//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum WCError: Error {
    case wrongURLFormat
    case tryingToConnectExistingSessionURL
    case tryingToDisconnectInactiveSession
    case wrongSessionFormat
}

public protocol WalletConnectDomainServiceDelegate: class {

    func didFailToConnect(url: WCURL)
    func shouldStart(session: WCSession, completion: (WCWalletInfo) -> Void)
    func didConnect(session: WCSession)
    func didDisconnect(session: WCSession)

}

public protocol WalletConnectDomainService {

    func connect(url: String) throws
    func reconnect(session: WCSession) throws
    func disconnect(session: WCSession) throws
    func openSessions() -> [WCSession]

}
