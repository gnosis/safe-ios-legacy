//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// This is a lightweight implementation of Observer design pattern. It is a simple Publisher - Subscriber mechanism,
/// where interested parties are registering closures to receive DomainEvents, and then other domain objects
/// publish events. Each subscriber is called on every publishing, in the order of subscription.
/// All subscribers can be removed using `reset()` method.
public class EventPublisher {

    private var subscribers = [String: [(DomainEvent) -> Void]]()

    public init () {}

    public func subscribe<T>(_ closure: @escaping (T) -> Void) where T: DomainEvent {
        let key = String(reflecting: T.self)
        if subscribers[key] == nil {
            subscribers[key] = []
        }
        subscribers[key]!.append { e in closure(e as! T) }
    }

    public func publish(_ event: DomainEvent) {
        let key = String(reflecting: type(of: event))
        subscribers[key]?.forEach { $0(event) }
    }

    public func reset() {
        subscribers = [:]
    }
}

public class DomainEvent {

    public init () {}

}
