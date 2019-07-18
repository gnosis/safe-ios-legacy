//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

public class FailedToConnectSession: DomainEvent {}
public class SessionUpdated: DomainEvent {}
public class SendTransactionRequested: DomainEvent {}

public typealias WCPendingTransaction = (request: WCSendTransactionRequest, completion: (Result<String, Error>) -> Void)

public class WalletConnectApplicationService {

    let chainId: Int
    private let onboardingKey = "io.gnosis.safe.MultisigWalletApplication.isWalletConnectOnboardingDone"

    private var service: WalletConnectDomainService { return DomainRegistry.walletConnectService }
    private var walletService: WalletApplicationService { return ApplicationServiceRegistry.walletService }
    private var eventRelay: EventRelay { return ApplicationServiceRegistry.eventRelay }
    private var eventPublisher: EventPublisher { return  DomainRegistry.eventPublisher }
    private var sessionRepo: WalletConnectSessionRepository { return DomainRegistry.walletConnectSessionRepository }
    private var ethereumNodeService: EthereumNodeDomainService { return DomainRegistry.ethereumNodeService }

    internal var pendingTransactions = [WCPendingTransaction]()

    private enum Strings {
        static let safeDescription = LocalizedString("ios_app_slogan", comment: "App slogan")
    }

    public init(chainId: Int) {
        self.chainId = chainId
    }

    public func setUp() {
        service.updateDelegate(self)
    }

    public var isAvaliable: Bool {
        return walletService.hasReadyToUseWallet
    }

    public func connect(url: String) throws {
        try service.connect(url: url)
    }

    public func reconnect(session: WCSession) throws {
        try service.reconnect(session: session)
    }

    public func disconnect(sessionID: BaseID) throws {
        guard let session = sessionRepo.find(id: WCSessionID(sessionID.id)) else { return }
        try service.disconnect(session: session)
    }

    public func sessions() -> [WCSessionData] {
        return service.openSessions().map { WCSessionData(wcSession: $0) }
    }

    public func subscribeForSessionUpdates(_ subscriber: EventSubscriber) {
        eventRelay.subscribe(subscriber, for: SessionUpdated.self)
    }

    public func popPendingTransactions() -> [WCPendingTransaction] {
        defer {
            pendingTransactions = []
        }
        return pendingTransactions
    }

    // MARK: Getting Started

    /// Returns status of the Wallet Connect onboarding
    ///
    /// - Returns: true if onboarding was marked as done, false otherwise
    open func isOnboardingDone() -> Bool {
        return DomainRegistry.appSettingsRepository.setting(for: onboardingKey) as? Bool == true
    }

    /// After finishing onboarding, it should not be entered again
    open func markOnboardingDone() {
        DomainRegistry.appSettingsRepository.set(setting: true, for: onboardingKey)
    }

    /// If user decides that onboarding needed again, this would turn it on
    open func markOnboardingNeeded() {
        DomainRegistry.appSettingsRepository.remove(for: onboardingKey)
    }

}

extension WalletConnectApplicationService: WalletConnectDomainServiceDelegate {

    public func didFailToConnect(url: WCURL) {
        eventPublisher.publish(FailedToConnectSession())
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

    public func didConnect(session: WCSession) {
        sessionRepo.save(session)
        eventPublisher.publish(SessionUpdated())
    }

    public func didDisconnect(session: WCSession) {
        sessionRepo.remove(session)
        eventPublisher.publish(SessionUpdated())
    }

    public func handleSendTransactionRequest(_ request: WCSendTransactionRequest,
                                             completion: @escaping (Result<String, Error>) -> Void) {
        pendingTransactions.append((request: request, completion: completion))
        eventPublisher.publish(SendTransactionRequested())
    }

    public func handleEthereumNodeRequest(_ request: WCMessage, completion: (Result<WCMessage, Error>) -> Void) {
        do {
            let response = try ethereumNodeService.rawCall(payload: request.payload)
            completion(.success(WCMessage(payload: response, url: request.url)))
        } catch {
            completion(.failure(error))
        }
    }

}
