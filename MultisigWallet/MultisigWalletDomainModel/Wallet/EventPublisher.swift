//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// This is a lightweight implementation of Observer design pattern. It is a simple Publisher - Subscriber mechanism,
/// where interested parties are registering closures to receive DomainEvents, and then other domain objects
/// publish events. Each subscriber is called on every publishing, in the order of subscription.
/// All subscribers can be removed using `reset()` method.
public class EventPublisher {

    private var subscriptions = [(type: DomainEvent.Type, closure: (DomainEvent) -> Void)]()

    public init () {}

    public func subscribe<T>(_ closure: @escaping (T) -> Void) where T: DomainEvent {
        subscriptions.append((T.self, { c in closure(c as! T) }))
    }

    public func publish(_ event: DomainEvent) {
        subscriptions.filter { $0.type == type(of: event) || $0.type == DomainEvent.self }.forEach { $0.closure(event) }
    }

    public func reset() {
        subscriptions = []
    }

}

open class DomainEvent {

    public init () {}

}
