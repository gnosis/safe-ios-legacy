//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class EventPublisherTests: XCTestCase {

    func test_publishesEvent() {
        class MyEvent: DomainEvent { }
        let publisher = EventPublisher()
        let exp = expectation(description: "receiving event")
        publisher.subscribe { (_: MyEvent) in
            exp.fulfill()
        }
        publisher.publish(MyEvent())
        waitForExpectations(timeout: 0.1)
    }

}
