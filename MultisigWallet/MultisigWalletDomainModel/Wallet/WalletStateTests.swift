//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class WalletStateTests: XCTestCase {

    let publisher = MockEventPublisher()
    let wallet = Wallet(id: WalletID(), owner: Address.testAccount1)

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: publisher, for: EventPublisher.self)
    }

    func test_stateConditions() {
        XCTAssertTrue(DraftState(wallet: wallet).canChangeOwners)
        XCTAssertTrue(ReadyToUseState(wallet: wallet).canChangeOwners)
        XCTAssertTrue(FinalizingDeploymentState(wallet: wallet).canChangeTransactionHash)
        XCTAssertTrue(DeployingState(wallet: wallet).canChangeAddress)
    }

    func test_whenComingToDeployingState_thenPostsEvent() {
        publisher.expectToPublish(DeploymentStarted.self)
        wallet.state.proceed()
        publisher.verify()
    }

}

class MockEventPublisher: EventPublisher {

    var expectedToPublish = [DomainEvent.Type]()

    func expectToPublish(_ event: DomainEvent.Type) {
        expectedToPublish.append(event)
    }

    var actuallyPublished = [DomainEvent.Type]()

    override func publish(_ event: DomainEvent) {
        actuallyPublished.append(type(of: event))
    }

    func verify(_ line: UInt = #line) {
        XCTAssertEqual(actuallyPublished.map { String(reflecting: $0) },
                       expectedToPublish.map { String(reflecting: $0) },
                       line: line)
    }

    override func reset() {
        expectedToPublish = []
        actuallyPublished = []
    }

}
