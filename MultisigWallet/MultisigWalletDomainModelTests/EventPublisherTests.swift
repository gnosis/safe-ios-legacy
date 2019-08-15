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
        publisher.subscribe(self) { (_: MyEvent) in
            exp.fulfill()
        }
        publisher.publish(MyEvent())
        waitForExpectations(timeout: 0.1)
    }

    func test_whenReset_thenSubscriberRemoved() {
        var didReceive = false
        publisher.subscribe(self) { (_: MyEvent) in
            didReceive = true
        }
        publisher.unsubscribe(self)
        publisher.publish(MyEvent())
        XCTAssertFalse(didReceive)
    }

    func test_whenSubscribingForDomainEventType_thenReceivesAllEvents() {
        let exp = self.expectation(description: "event")
        exp.expectedFulfillmentCount = 2
        publisher.subscribe(self) { (_: DomainEvent) in
            exp.fulfill()
        }
        publisher.publish(MyEvent())
        publisher.publish(OtherEvent())
        waitForExpectations(timeout: 0.1)
    }

}
