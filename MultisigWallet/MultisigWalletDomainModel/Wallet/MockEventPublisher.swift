//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockEventPublisher: EventPublisher {

    private var filteredEventTypes = [String]()
    private var expectedToPublish = [String]()
    private var actuallyPublished = [String]()

    public func addFilter(_ event: Any.Type) {
        filteredEventTypes.append(String(reflecting: event))
    }

    public func expectToPublish(_ event: DomainEvent.Type) {
        expectedToPublish.append(String(reflecting: event))
    }

    public func publishedWhatWasExpected() -> Bool {
        return actuallyPublished.map { String(reflecting: $0) } == expectedToPublish.map { String(reflecting: $0) }
    }

    override public func publish(_ event: DomainEvent) {
        guard filteredEventTypes.isEmpty || filteredEventTypes.contains(String(reflecting: type(of: event))) else {
            return
        }
        super.publish(event)
        actuallyPublished.append(String(reflecting: type(of: event)))
    }

    public func verify() -> Bool {
        return expectedToPublish == actuallyPublished
    }

}
