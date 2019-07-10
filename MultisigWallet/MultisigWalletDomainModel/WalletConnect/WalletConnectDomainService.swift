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

    /// Failed to establish a new connection.
    ///
    /// - Parameter url: WalletConnect url object
    func didFailToConnect(url: WCURL)

    /// Requesting permission to establish a new connection.
    ///
    /// - Parameters:
    ///   - session: WalletConnect session with dApp info
    ///   - completion: wallet info object
    func shouldStart(session: WCSession, completion: (WCWalletInfo) -> Void)

    /// WalletConnect session was connected.
    ///
    /// - Parameter session: WalletConnect session object
    func didConnect(session: WCSession)

    /// WalletConnect session was disconnected.
    ///
    /// - Parameter session: WalletConnect session object
    func didDisconnect(session: WCSession)

    /// Handle WalletConnect send transaction request.
    /// https://docs.walletconnect.org/json-rpc/ethereum#eth_sendtransaction
    ///
    /// - Parameters:
    ///   - request: WCSendTransactionRequest object
    ///   - completion: Result object with request hash or error
    func handleSendTransactionRequest(_ request: WCSendTransactionRequest,
                                      completion: @escaping (Result<String, Error>) -> Void)


    /// Handle WalletConnect Ethereum Node request.
    ///
    /// - Parameters:
    ///   - request: WCMessage object
    ///   - completion: WCMessage object
    func handleEthereumNodeRequest(_ request: WCMessage, completion: (WCMessage) -> Void)

}

public protocol WalletConnectDomainService {

    /// Connect to WalletConnect URL. Should not be called if WalletConnect session exists for this url.
    ///
    /// - Parameter url: URL string
    /// - Throws: wrong url format error or trying to connect existing session error
    func connect(url: String) throws

    /// Reconnect to WalletConnect session. This call can be triggered for already connected sessions.
    ///
    /// - Parameter session: WalletConnect session
    /// - Throws: wrong session format error
    func reconnect(session: WCSession) throws


    /// Disconnect WalletConnect session.
    ///
    /// - Parameter session: WalletConnect session
    /// - Throws: error if the session is already disconnected
    func disconnect(session: WCSession) throws

    /// Get the list of open sessions.
    ///
    /// - Returns: sessoins array
    func openSessions() -> [WCSession]

}
