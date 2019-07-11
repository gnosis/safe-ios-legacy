//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport

class WalletConnectApplicationServiceTests: XCTestCase {

    var appService: WalletConnectApplicationService!
    let walletService = MockWalletApplicationService()
    let domainService = MockWalletConnectDomainService()
    let repo = InMemoryWCSessionRepository()
    let eventPublisher = MockEventPublisher()
    let subscriber = MockSubscriber()
    var relayService: MockEventRelay!
    let ethereumNodeService = MockEthereumNodeService()

    override func setUp() {
        super.setUp()
        relayService = MockEventRelay(publisher: eventPublisher)
        DomainRegistry.put(service: domainService, for: WalletConnectDomainService.self)
        DomainRegistry.put(service: repo, for: WalletConnectSessionRepository.self)
        DomainRegistry.put(service: eventPublisher, for: EventPublisher.self)
        DomainRegistry.put(service: ethereumNodeService, for: EthereumNodeDomainService.self)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        ApplicationServiceRegistry.put(service: relayService, for: EventRelay.self)
        appService = WalletConnectApplicationService(chainId: 1)
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

    func test_disconnect_callsDomainService() throws {
        repo.save(WCSession.testSession)
        try appService.disconnect(sessionID: WCSession.testSession.id)
        XCTAssertEqual(domainService.disconnectSession, WCSession.testSession)
    }

    func test_disconnect_whenDomainServiceThrows_thenThrows() {
        repo.save(WCSession.testSession)
        domainService.shouldThrow = true
        XCTAssertThrowsError(try appService.disconnect(sessionID: WCSession.testSession.id))
    }

    func test_disconnect_whenSessionIsNotFoundInRepo_thenIgnores() {
        domainService.shouldThrow = true
        XCTAssertNoThrow(try appService.disconnect(sessionID: WCSession.testSession.id))
        XCTAssertNil(domainService.disconnectSession)
    }

    func test_sessions() {
        domainService.sessions = [WCSession.testSession]
        XCTAssertEqual(appService.sessions().count, 1)
    }

    func test_subscribeForSessionUpdates() {
        relayService.expect_subscribe(subscriber, for: SessionUpdated.self)
        appService.subscribeForSessionUpdates(subscriber)
        XCTAssertTrue(relayService.verify())
    }

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

    func test_didConnect_savesSession() {
        XCTAssertTrue(repo.all().isEmpty)
        appService.didConnect(session: WCSession.testSession)
        XCTAssertEqual(repo.find(id: WCSession.testSession.id), WCSession.testSession)
    }

    func test_didConnect_publishesEvent() {
        eventPublisher.expectToPublish(SessionUpdated.self)
        appService.didConnect(session: WCSession.testSession)
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

    var sessions = [WCSession]()
    func openSessions() -> [WCSession] {
        return sessions
    }

}
