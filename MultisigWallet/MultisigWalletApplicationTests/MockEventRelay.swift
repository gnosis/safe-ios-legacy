//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import MultisigWalletDomainModel
@testable import MultisigWalletApplication

class MockEventRelay: EventRelay {

    private var expected_subscribe = [(subject: EventSubscriber, event: DomainEvent.Type)]()
    private var actual_subscribe = [(subject: EventSubscriber, event: DomainEvent.Type)]()

    func expect_subscribe(_ subject: EventSubscriber, for event: DomainEvent.Type) {
        expected_subscribe.append((subject, event))
    }

    override func subscribe(_ subject: EventSubscriber, for event: DomainEvent.Type) {
        actual_subscribe.append((subject, event))
    }

    private var expected_unsubscribe = [EventSubscriber]()
    private var actual_unsubscribe = [EventSubscriber]()

    public func expect_unsubscribe(_ subject: EventSubscriber) {
        expected_unsubscribe.append(subject)
    }

    override func unsubscribe(_ subject: EventSubscriber) {
        actual_unsubscribe.append(subject)
    }

    public func verify() -> Bool {
        return
            actual_subscribe.count == expected_subscribe.count &&
            zip(actual_subscribe, expected_subscribe).reduce(true) { result, pair -> Bool in
                result && pair.0.subject === pair.1.subject && pair.0.event == pair.1.event
            } &&
            actual_unsubscribe.count == expected_unsubscribe.count &&
            zip(actual_unsubscribe, expected_unsubscribe).reduce(true) { $0 && $1.0 === $1.1 }
    }

}
