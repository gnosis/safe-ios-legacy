//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class EventPublisherTests: XCTestCase {

    class MyEvent: DomainEvent {}
    class OtherEvent: DomainEvent {}

    let publisher = EventPublisher()

    func test_publishesEvent() {
        let exp = expectation(description: "receiving event")
        publisher.subscribe { (_: MyEvent) in
            exp.fulfill()
        }
        publisher.publish(MyEvent())
        waitForExpectations(timeout: 0.1)
    }

    func test_whenReset_thenSubscriberRemoved() {
        var didReceive = false
        publisher.subscribe { (_: MyEvent) in
            didReceive = true
        }
        publisher.reset()
        publisher.publish(MyEvent())
        XCTAssertFalse(didReceive)
    }

    func test_whenSubscribingForDomainEventType_thenReceivesAllEvents() {
        var didReceive = 0
        publisher.subscribe { (_: DomainEvent) in
            didReceive += 1
        }
        publisher.publish(MyEvent())
        publisher.publish(OtherEvent())
        XCTAssertEqual(didReceive, 2)
    }

}
