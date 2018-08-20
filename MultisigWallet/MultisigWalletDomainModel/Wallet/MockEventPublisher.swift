//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockEventPublisher: EventPublisher {

    private var expectedToPublish = [DomainEvent.Type]()

    public func expectToPublish(_ event: DomainEvent.Type) {
        expectedToPublish.append(event)
    }

    private var actuallyPublished = [DomainEvent.Type]()

    override public func publish(_ event: DomainEvent) {
        actuallyPublished.append(type(of: event))
    }

    public func publishedWhatWasExpected() -> Bool {
        return actuallyPublished.map { String(reflecting: $0) } == expectedToPublish.map { String(reflecting: $0) }
    }

}
