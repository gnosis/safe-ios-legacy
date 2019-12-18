//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import WalletConnectSwift

// TODO: make this service very thin and move domain specific logic to special new domain object.
public class WalletConnectService: WalletConnectDomainService {

    private weak var delegate: WalletConnectDomainServiceDelegate!

    var server: Server!

    enum ErrorCode: Int {
        case declinedSendTransactionRequest = -10_000
        case wrongSendTransactionRequest = -10_001
        case wrongNodeRPCResponse = -10_002
        case failedToExecuteNodeRPCRequest = -10_003
    }

    public init() {
        server = Server(delegate: self)
        server.register(handler: self)
    }

    public func updateDelegate(_ delegate: WalletConnectDomainServiceDelegate) {
        self.delegate = delegate
    }

    public func connect(url: String) throws {
        guard let wcurl = WCURL(url) else { throw WCError.wrongURLFormat }
        do {
            // Stub data will be updated with real data once the connection is established.
            let stubURL = URL(string: "https://safe.gnosis.io")!
            let stubMeta = WCClientMeta(name: "", description: "", icons: [], url: stubURL)
            let isMobile = url.contains("&isMobile=true")
            let newSession = WCSession(url: wcurl.wcURL,
                                       dAppInfo: WCDAppInfo(peerId: "", peerMeta: stubMeta, isMobile: isMobile),
                                       walletInfo: nil,
                                       status: .connecting)
            DomainRegistry.walletConnectSessionRepository.save(newSession)
            try server.connect(to: wcurl)
        } catch {
            throw WCError.tryingToConnectExistingSessionURL
        }
    }

    public func reconnect(session: WCSession) throws {
        guard session.walletInfo != nil else {
            // Trying to reconnect a session without handshake process finished.
            // It could happed when the app restarts in the middle of the process.
            DomainRegistry.walletConnectSessionRepository.remove(session)
            return
        }
        do {
            try server.reconnect(to: Session(wcSession: session))
        } catch {
            throw WCError.wrongSessionFormat
        }
    }

    public func disconnect(session: WCSession) throws {
        guard session.walletInfo != nil else {
            DomainRegistry.walletConnectSessionRepository.remove(session)
            return
        }
        do {
            try server.disconnect(from: Session(wcSession: session))
        } catch {
            throw WCError.tryingToDisconnectInactiveSession
        }
    }

    public func sessions() -> [WCSession] {
        return DomainRegistry.walletConnectSessionRepository.all().sorted { $0.created > $1.created }
    }

}

extension WalletConnectService: ServerDelegate {

    public func server(_ server: Server, didFailToConnect url: WalletConnectSwift.WCURL) {
        delegate.didFailToConnect(url: url.wcURL)
    }

    public func server(_ server: Server, shouldStart session: Session, completion: (Session.WalletInfo) -> Void) {
        guard let existingSession = findExistingWCSession(for: session) else { return }
        delegate.shouldStart(session: session.wcSession(status: .connecting,
                                                        created: existingSession.created,
                                                        isMobile: existingSession.isMobile)) { wcWalletInfo in
            completion(Session.WalletInfo(wcWalletInfo: wcWalletInfo))
        }
    }

    public func server(_ server: Server, didConnect session: Session) {
        guard let existingSession = findExistingWCSession(for: session) else { return }
        let updatedSession = session.wcSession(status: .connected,
                                               created: existingSession.created,
                                               isMobile: existingSession.isMobile)
        DomainRegistry.walletConnectSessionRepository.save(updatedSession)
        delegate.didConnect(session: updatedSession)
    }

    public func server(_ server: Server, didDisconnect session: Session) {
        guard let existingSession = findExistingWCSession(for: session) else { return }
        DomainRegistry.walletConnectSessionRepository.remove(existingSession)
        delegate.didDisconnect(session: session.wcSession(status: .disconnected,
                                                          created: existingSession.created,
                                                          isMobile: existingSession.isMobile))
    }

    private func findExistingWCSession(for session: Session) -> WCSession? {
        return DomainRegistry.walletConnectSessionRepository.find(id: WCSessionID(session.url.topic))
    }

}

extension WalletConnectService: RequestHandler {

    var unsupportedWalletConnectRequests: [String] {
        return ["personal_sign", "eth_sign", "eth_signTypedData", "eth_signTransaction", "eth_sendRawTransaction"]
    }

    public func canHandle(request: Request) -> Bool {
        return !unsupportedWalletConnectRequests.contains(request.method)
    }

    // swiftlint:disable:next function_body_length
    public func handle(request: Request) {
        if request.method == "eth_sendTransaction" {
            do {
                var wcRequest = try request.parameter(of: WCSendTransactionRequest.self, at: 0)
                wcRequest.url = request.url.wcURL
                let completion = createSendTransactionCompletionBlock(with: request)
                delegate.handleSendTransactionRequest(wcRequest, completion: completion)
            } catch {
                handleSendTransactionFailure(request, error)
            }
        } else if request.method == "gs_multi_send" {
            do {
                let subtransactions = try (0..<request.parameterCount).map { index in
                    try request.parameter(of: WCMultiSendSubTransaction.self, at: index)
                }
                let wcRequest = WCMultiSendRequest(subtransactions: subtransactions, url: request.url.wcURL)
                let completion = createSendTransactionCompletionBlock(with: request)
                delegate.handleMultiSendTransactionRequest(wcRequest, completion: completion)
            } catch {
                handleSendTransactionFailure(request, error)
            }
        } else {
            let completion = createEthereumNodeRequestCompletionBlock(with: request)
            delegate.handleEthereumNodeRequest(request.wcRequest, completion: completion)
        }
    }

    private func createSendTransactionCompletionBlock(with request: Request) -> (Result<String, Error>) -> Void {
        { [weak self] result in
            guard let `self` = self else { return }
            var response: Response
            switch result {
            case .success(let hash):
                response = try! Response(url: request.url, value: hash, id: request.id!)
            case .failure(let error):
                let errorMessage = "Transaction was declined. Error: \(error.localizedDescription)"
                response = try! Response(url: request.url,
                                         errorCode: ErrorCode.declinedSendTransactionRequest.rawValue,
                                         message: errorMessage,
                                         id: request.id)
            }
            self.server.send(response)
        }
    }

    private func handleSendTransactionFailure(_ request: Request, _ error: Error) {
        DomainRegistry.logger.error("WC: failed \(request.method)", error: error)
        let errorMessage = "Wrong request. Error: \(error.localizedDescription)."
        let response = try! Response(url: request.url,
                                     errorCode: ErrorCode.wrongSendTransactionRequest.rawValue,
                                     message: errorMessage,
                                     id: request.id)
        self.server.send(response)
    }

    private func createEthereumNodeRequestCompletionBlock(with request: Request) -> (Result<WCMessage, Error>) -> Void {
        { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let wcResponse):
                do {
                    let response = try Response(wcResponse: wcResponse)
                    self.server.send(response)
                } catch {
                    let message = "WC: Could not create a WalletConnect Response from: \(wcResponse.payload)"
                    DomainRegistry.logger.error(message, error: error)
                    let errorMessage = "Wrong RPC response. Error: \(error.localizedDescription)"
                    let response = try! Response(url: request.url,
                                                 errorCode: ErrorCode.wrongNodeRPCResponse.rawValue,
                                                 message: errorMessage,
                                                 id: request.id)
                    self.server.send(response)
                }
            case .failure(let error):
                let internalMessage = """
                WC: Could not send a WalletConnect request: \(request.method). Error: \(error.localizedDescription)
                """
                DomainRegistry.logger.error(internalMessage, error: error)
                let errorMessage = "RPC request failed. Error: \(error.localizedDescription)"
                let response = try! Response(url: request.url,
                                             errorCode: ErrorCode.failedToExecuteNodeRPCRequest.rawValue,
                                             message: errorMessage,
                                             id: request.id)
                self.server.send(response)
            }
        }
    }

}

extension WalletConnectSwift.WCURL {

    init(wcURL: MultisigWalletDomainModel.WCURL) {
        self.init(topic: wcURL.topic, version: wcURL.version, bridgeURL: wcURL.bridgeURL, key: wcURL.key)
    }

    var wcURL: MultisigWalletDomainModel.WCURL {
        return MultisigWalletDomainModel.WCURL(topic: topic, version: version, bridgeURL: bridgeURL, key: key)
    }

}

extension Session.ClientMeta {

    init(wcClientMeta: WCClientMeta) {
        self.init(name: wcClientMeta.name,
                  description: wcClientMeta.description,
                  icons: wcClientMeta.icons,
                  url: wcClientMeta.url)
    }

    var wcClientMeta: WCClientMeta {
        return WCClientMeta(name: name, description: description ?? "", icons: icons, url: url)
    }

}

extension Session.DAppInfo {

    init(wcDAppInfo: WCDAppInfo) {
        self.init(peerId: wcDAppInfo.peerId, peerMeta: Session.ClientMeta(wcClientMeta: wcDAppInfo.peerMeta))
    }

}

extension Session.WalletInfo {

    init(wcWalletInfo: WCWalletInfo) {
        self.init(approved: wcWalletInfo.approved,
                  accounts: wcWalletInfo.accounts,
                  chainId: wcWalletInfo.chainId,
                  peerId: wcWalletInfo.peerId,
                  peerMeta: Session.ClientMeta(wcClientMeta: wcWalletInfo.peerMeta))
    }

    var wcWalletInfo: WCWalletInfo {
        return WCWalletInfo(approved: approved,
                            accounts: accounts,
                            chainId: chainId,
                            peerId: peerId,
                            peerMeta: peerMeta.wcClientMeta)
    }

}

extension Session {

    init(wcSession: WCSession) {
        self.init(url: WalletConnectSwift.WCURL(wcURL: wcSession.url),
                  dAppInfo: DAppInfo(wcDAppInfo: wcSession.dAppInfo),
                  walletInfo: Session.WalletInfo(wcWalletInfo: wcSession.walletInfo!))
    }

    func wcSession(status: WCSessionStatus, created: Date, isMobile: Bool) -> WCSession {
        let dappInfo = WCDAppInfo(peerId: dAppInfo.peerId,
                                  peerMeta: dAppInfo.peerMeta.wcClientMeta,
                                  isMobile: isMobile)
        return WCSession(url: url.wcURL,
                         dAppInfo: dappInfo,
                         walletInfo: walletInfo?.wcWalletInfo,
                         status: status,
                         created: created)
    }

}

extension Request {

    var wcRequest: WCMessage {
        return WCMessage(payload: jsonString, url: url.wcURL)
    }

}

extension Response {

    convenience init(wcResponse: WCMessage) throws {
        let url = WalletConnectSwift.WCURL(wcURL: wcResponse.url)
        try self.init(url: url, jsonString: wcResponse.payload)
    }

}
