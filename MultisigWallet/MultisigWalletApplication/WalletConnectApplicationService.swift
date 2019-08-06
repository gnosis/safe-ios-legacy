//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

public class FailedToConnectSession: DomainEvent {}
public class SessionUpdated: DomainEvent {}
public class SendTransactionRequested: DomainEvent {}
public class NonceUpdated: DomainEvent {}

extension WCSendTransactionRequest: SendTransactionRequiredData {}

public class WalletConnectApplicationService {

    // TODO: move to domain service
    let chainId: Int
    let pendingTransactionsRepository = WCPendingTransactionsRepository()

    private let onboardingKey = "io.gnosis.safe.MultisigWalletApplication.isWalletConnectOnboardingDone"

    private var service: WalletConnectDomainService { return DomainRegistry.walletConnectService }
    private var walletService: WalletApplicationService { return ApplicationServiceRegistry.walletService }
    private var walletRepository: WalletRepository { return DomainRegistry.walletRepository }
    private var eventRelay: EventRelay { return ApplicationServiceRegistry.eventRelay }
    private var eventPublisher: EventPublisher { return  DomainRegistry.eventPublisher }
    private var sessionRepo: WalletConnectSessionRepository { return DomainRegistry.walletConnectSessionRepository }
    private var ethereumNodeService: EthereumNodeDomainService { return DomainRegistry.ethereumNodeService }
    private var appSettingsRepository: AppSettingsRepository { return DomainRegistry.appSettingsRepository }
    private var transactionsRepository: TransactionRepository { return DomainRegistry.transactionRepository }

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
        eventPublisher.publish(SessionUpdated())
    }

    public func reconnect(session: WCSession) throws {
        try service.reconnect(session: session)
    }

    public func disconnect(sessionID: BaseID) throws {
        guard let session = sessionRepo.find(id: WCSessionID(sessionID.id)) else { return }
        try service.disconnect(session: session)
        eventPublisher.publish(SessionUpdated())
    }

    public func sessions() -> [WCSessionData] {
        return service.sessions().map { WCSessionData(wcSession: $0) }
    }

    public func subscribeForSessionUpdates(_ subscriber: EventSubscriber) {
        eventRelay.subscribe(subscriber, for: SessionUpdated.self)
    }

    public func subscribeForIncomingTransactions(_ subscriber: EventSubscriber) {
        eventRelay.subscribe(subscriber, for: SendTransactionRequested.self)
    }

    public func subcribeForNonceApdates(_ subscriber: EventSubscriber) {
        eventRelay.subscribe(subscriber, for: NonceUpdated.self)
    }

    public func popPendingTransactions() -> [WCPendingTransaction] {
        return pendingTransactionsRepository.popAll()
    }

    // MARK: Getting Started

    /// Returns status of the Wallet Connect onboarding
    ///
    /// - Returns: true if onboarding was marked as done, false otherwise
    open func isOnboardingDone() -> Bool {
        return appSettingsRepository.setting(for: onboardingKey) as? Bool == true
    }

    /// After finishing onboarding, it should not be entered again
    open func markOnboardingDone() {
        appSettingsRepository.set(setting: true, for: onboardingKey)
    }

    /// If user decides that onboarding needed again, this would turn it on
    open func markOnboardingNeeded() {
        appSettingsRepository.remove(for: onboardingKey)
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
        eventPublisher.publish(SessionUpdated())
    }

    public func didDisconnect(session: WCSession) {
        eventPublisher.publish(SessionUpdated())
    }

    // TODO: move to domain service
    public func handleSendTransactionRequest(_ request: WCSendTransactionRequest,
                                             completion: @escaping (Result<String, Error>) -> Void) {
        guard let wcSession = sessionRepo.find(url: request.url) else { return }
        let wallet = walletRepository.selectedWallet()!
        let txID = walletService.createDraftTransaction(in: wallet, sendTransactionData: request)
        guard let tx = transactionsRepository.find(id: txID), !tx.isDangerous() else {
            let error = NSError(domain: "io.gnosis.safe",
                                code: -501,
                                userInfo: [NSLocalizedDescriptionKey: "Attempt to perform a restricted transaction."])
            completion(.failure(error))
            return
        }
        let sessionData = WCSessionData(wcSession: wcSession)
        let transaction = WCPendingTransaction(transactionID: txID, sessionData: sessionData, completion: completion)
        pendingTransactionsRepository.add(transaction)
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
