//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import MultisigWalletImplementations

class WalletConnectApplicationServiceTests: XCTestCase {

    var appService: WalletConnectApplicationService!
    let domainService = MockWalletConnectDomainService()
    let repo = InMemoryWCSessionRepository()
    let eventPublisher = MockEventPublisher()
    var relayService: MockEventRelay!

    override func setUp() {
        super.setUp()
        relayService = MockEventRelay(publisher: eventPublisher)
        DomainRegistry.put(service: domainService, for: WalletConnectDomainService.self)
        DomainRegistry.put(service: repo, for: WalletConnectSessionRepository.self)
        DomainRegistry.put(service: eventPublisher, for: EventPublisher.self)
        ApplicationServiceRegistry.put(service: relayService, for: EventRelay.self)
        appService = WalletConnectApplicationService(chainId: 1)
    }

    func test_init_setsDelegate() {
        XCTAssertTrue(domainService.delegate === appService)
    }

    func test_isAvailable() {
    }

    func test_connect_callsDomainService() {
    }

    func test_connect_whenDomainServiceThrows_thenThrows() {
    }

    func test_disconnect_callsDomainService() {
    }

    func test_disconnect_whenDomainServiceThrows_thenThrows() {
    }

    func test_sessions() {
    }

    func test_subscribeForSessionUpdates() {
    }

    func test_didFailToConnect_publishesEvent() {
    }

    func test_shouldStar_approvesConnection() {
    }

    func test_didConnect_savesSession() {
    }

    func test_didConnect_publishesEvent() {
    }

}

class MockWalletConnectDomainService: WalletConnectDomainService {

    var delegate: WalletConnectDomainServiceDelegate!
    func updateDelegate(_ delegate: WalletConnectDomainServiceDelegate) {
        self.delegate = delegate
    }

    var connectUrl: String?
    func connect(url: String) throws {
        connectUrl = url
    }

    var reconnectSession: WCSession?
    func reconnect(session: WCSession) throws {
        reconnectSession = session
    }

    var disconnectSession: WCSession?
    func disconnect(session: WCSession) throws {
        disconnectSession = session
    }

    var sessions = [WCSession]()
    func openSessions() -> [WCSession] {
        return sessions
    }

}
