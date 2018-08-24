//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import MultisigWalletDomainModel
@testable import MultisigWalletApplication

class MockEventRelay: EventRelay {

    private var expected_reset = [String]()
    private var actual_reset = [String]()

    public func expect_reset() {
        expected_reset.append("reset(publisher:)")
    }

    public override func reset(publisher: EventPublisher) {
        actual_reset.append(#function)
    }

    private var expected_subscribe = [(subject: EventSubscriber, event: DomainEvent.Type)]()
    private var actual_subscribe = [(subject: EventSubscriber, event: DomainEvent.Type)]()

    func expect_subscribe(_ subject: EventSubscriber, for event: DomainEvent.Type) {
        expected_subscribe.append((subject, event))
    }

    override func subscribe(_ subject: EventSubscriber, for event: DomainEvent.Type) {
        actual_subscribe.append((subject, event))
    }

    public func verify() -> Bool {
        return actual_reset == expected_reset &&
            actual_subscribe.count == expected_subscribe.count &&
            zip(actual_subscribe, expected_subscribe).reduce(true) { result, pair -> Bool in
                result && pair.0.subject === pair.1.subject && pair.0.event == pair.1.event
            }
    }

}
