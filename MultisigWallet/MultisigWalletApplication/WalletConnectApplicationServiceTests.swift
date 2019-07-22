//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport

class WalletConnectApplicationServiceTests: BaseWalletApplicationServiceTests {

    var appService: WalletConnectApplicationService!

    let walletService = MockWalletApplicationService()
    let domainService = MockWalletConnectDomainService()
    let sessionRepository = InMemoryWCSessionRepository()
    let subscriber = MockSubscriber()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: domainService, for: WalletConnectDomainService.self)
        DomainRegistry.put(service: sessionRepository, for: WalletConnectSessionRepository.self)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        appService = WalletConnectApplicationService(chainId: 1)
        appService.setUp()
    }

    func test_init_setsDelegate() {
        XCTAssertTrue(domainService.delegate === appService)
    }

    func test_isAvailable() {
        XCTAssertFalse(appService.isAvaliable)
        walletService.createReadyToUseWallet()
        XCTAssertTrue(appService.isAvaliable)
    }

    func test_connect_callsDomainService() throws {
        try appService.connect(url: "some")
        XCTAssertEqual(domainService.connectUrl, "some")
    }

    func test_connect_whenDomainServiceThrows_thenThrows() throws {
        domainService.shouldThrow = true
        XCTAssertThrowsError(try appService.connect(url: "some"))
    }

    func test_connect_publishesEvent() throws {
        eventPublisher.expectToPublish(SessionUpdated.self)
        try appService.connect(url: "some")
        XCTAssertTrue(eventPublisher.verify())
    }

    func test_reconnect_callsDomainService() throws {
        try appService.reconnect(session: WCSession.testSession)
        XCTAssertEqual(domainService.reconnectSession, WCSession.testSession)
    }

    func test_reconnect_whenDomainServiceThrows_thenThrows() {
        domainService.shouldThrow = true
        XCTAssertThrowsError(try appService.reconnect(session: WCSession.testSession))
    }

    func test_disconnect_callsDomainService() throws {
        sessionRepository.save(WCSession.testSession)
        try appService.disconnect(sessionID: WCSession.testSession.id)
        XCTAssertEqual(domainService.disconnectSession, WCSession.testSession)
    }

    func test_disconnect_whenDomainServiceThrows_thenThrows() {
        sessionRepository.save(WCSession.testSession)
        domainService.shouldThrow = true
        XCTAssertThrowsError(try appService.disconnect(sessionID: WCSession.testSession.id))
    }

    func test_disconnect_whenSessionIsNotFoundInRepo_thenIgnores() {
        domainService.shouldThrow = true
        XCTAssertNoThrow(try appService.disconnect(sessionID: WCSession.testSession.id))
        XCTAssertNil(domainService.disconnectSession)
    }

    func test_disconnect_publishesEvent() throws {
        sessionRepository.save(WCSession.testSession)
        eventPublisher.expectToPublish(SessionUpdated.self)
        try appService.disconnect(sessionID: WCSession.testSession.id)
        XCTAssertTrue(eventPublisher.verify())
    }

    func test_sessions() {
        domainService.sessionsArray = [WCSession.testSession]
        XCTAssertEqual(appService.sessions().count, 1)
    }

    func test_subscribeForSessionUpdates() {
        eventRelay.expect_subscribe(subscriber, for: SessionUpdated.self)
        appService.subscribeForSessionUpdates(subscriber)
        XCTAssertTrue(eventRelay.verify())
    }

    func test_subscribeForIncomingTransactions() {
        eventRelay.expect_subscribe(subscriber, for: SendTransactionRequested.self)
        appService.subscribeForIncomingTransactions(subscriber)
        XCTAssertTrue(eventRelay.verify())
    }

    func test_subcribeForNonceApdates() {
        eventRelay.expect_subscribe(subscriber, for: NonceUpdated.self)
        appService.subcribeForNonceApdates(subscriber)
        XCTAssertTrue(eventRelay.verify())
    }

    func test_popPendingTransactions_after_handleSendTransactionRequest() {
        let testRequest = prepareRequestForHandling()
        XCTAssertTrue(appService.popPendingTransactions().isEmpty)
        appService.handleSendTransactionRequest(testRequest) { _ in }
        let wcTransacitons = appService.popPendingTransactions()
        XCTAssertEqual(wcTransacitons.count, 1)
        let transaction = transactionRepository.find(id: wcTransacitons[0].transactionID)!
        XCTAssertEqual(transaction.sender, testRequest.from)
        XCTAssertEqual(transaction.recipient, testRequest.to)
        XCTAssertEqual(transaction.ethValue, testRequest.value)
        XCTAssertEqual(transaction.data, testRequest.data)
        XCTAssertTrue(appService.popPendingTransactions().isEmpty)
    }

    // MARK: - WalletConnectDomainServiceDelegate

    func test_didFailToConnect_publishesEvent() {
        eventPublisher.expectToPublish(FailedToConnectSession.self)
        appService.didFailToConnect(url: WCURL.testURL)
        XCTAssertTrue(eventPublisher.verify())
    }

    func test_shouldStar_approvesConnection() {
        walletService.createReadyToUseWallet()
        let exp = expectation(description: "Waiting for approval")
        appService.shouldStart(session: WCSession.testSession) { info in
            XCTAssertTrue(info.approved)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func test_didConnect_publishesEvent() {
        eventPublisher.expectToPublish(SessionUpdated.self)
        appService.didConnect(session: WCSession.testSession)
        XCTAssertTrue(eventPublisher.verify())
    }

    func test_didDisconnect_publishedEvent() {
        eventPublisher.expectToPublish(SessionUpdated.self)
        appService.didDisconnect(session: WCSession.testSession)
        XCTAssertTrue(eventPublisher.verify())
    }

    func test_handleSendTransactionRequest_publeshesEvent() {
        eventPublisher.expectToPublish(SendTransactionRequested.self)
        let testRequest = prepareRequestForHandling()
        appService.handleSendTransactionRequest(testRequest) { _ in }
        XCTAssertTrue(eventPublisher.verify())
    }

    func test_handleEthereumNodeRequest_callsEthereumNodeService() {
        XCTAssertNil(ethereumNodeService.rawCall_input)
        let exp = expectation(description: "call ethereum node service")
        appService.handleEthereumNodeRequest(WCMessage.testMessage) { response in
            if case Result.success(_) = response {
                exp.fulfill()
            }
        }
        XCTAssertNotNil(ethereumNodeService.rawCall_input)
        waitForExpectations(timeout: 1)
    }

    func test_handleEthereumNodeRequest_whenThrows_thenReturnsErrorInCompletion() {
        ethereumNodeService.shouldThrow = true
        let exp = expectation(description: "call ethereum node service")
        appService.handleEthereumNodeRequest(WCMessage.testMessage) { response in
            if case Result.failure(_) = response {
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }

    private func prepareRequestForHandling() -> WCSendTransactionRequest {
        givenReadyToUseWallet()
        sessionRepository.save(WCSession.testSession)
        var testRequest = WCSendTransactionRequest.testRequest
        testRequest.url = WCURL.testURL
        return testRequest
    }

}

class MockWalletConnectDomainService: WalletConnectDomainService {

    var shouldThrow = false

    weak var delegate: WalletConnectDomainServiceDelegate!
    func updateDelegate(_ delegate: WalletConnectDomainServiceDelegate) {
        self.delegate = delegate
    }

    var connectUrl: String?
    func connect(url: String) throws {
        if shouldThrow { throw TestError.error }
        connectUrl = url
    }

    var reconnectSession: WCSession?
    func reconnect(session: WCSession) throws {
        if shouldThrow { throw TestError.error }
        reconnectSession = session
    }

    var disconnectSession: WCSession?
    func disconnect(session: WCSession) throws {
        if shouldThrow { throw TestError.error }
        disconnectSession = session
    }

    var sessionsArray = [WCSession]()
    func sessions() -> [WCSession] {
        return sessionsArray
    }

}
