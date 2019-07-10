//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class FailedToConnectSession: DomainEvent {}
public class SessionUpdated: DomainEvent {}

public class WalletConnectApplicationService {

    let chainId: Int

    private var service: WalletConnectDomainService {
        return DomainRegistry.walletConnectService
    }

    private enum Strings {
        static let safeDescription = LocalizedString("ios_app_slogan", comment: "App slogan")
    }

    public init(chainId: Int) {
        self.chainId = chainId
        service.updateDelegate(self)
    }

    public var isAvaliable: Bool {
        return ApplicationServiceRegistry.walletService.hasReadyToUseWallet
    }

    public func connect(url: String) throws {
        try service.connect(url: url)
    }

    public func disconnect(session: WCSession) {

    }

    public func sessions() -> [WCSession] { return [] }

    public func subscribeForSessionUpdates(_ subscriber: EventSubscriber) {}

}

extension WalletConnectApplicationService: WalletConnectDomainServiceDelegate {

    public func didFailToConnect(url: WCURL) {
        DomainRegistry.eventPublisher.publish(FailedToConnectSession())
    }

    public func shouldStart(session: WCSession, completion: (WCWalletInfo) -> Void) {
        let walletMeta = WCClientMeta(name: "Gnosis Safe",
                                      description: Strings.safeDescription,
                                      icons: [],
                                      url: URL(string: "https://safe.gnosis.io")!)
        let walletInfo = WCWalletInfo(approved: true,
                                      accounts: [ApplicationServiceRegistry.walletService.selectedWalletAddress!],
                                      chainId: chainId,
                                      peerId: UUID().uuidString,
                                      peerMeta: walletMeta)
        completion(walletInfo)
    }

    public func didConnect(session: WCSession) {}

    public func didDisconnect(session: WCSession) {}

    public func handleSendTransactionRequest(_ request: WCSendTransactionRequest,
                                             completion: @escaping (Result<String, Error>) -> Void) {}

    public func handleEthereumNodeRequest(_ request: WCMessage, completion: (WCMessage) -> Void) {}


}
