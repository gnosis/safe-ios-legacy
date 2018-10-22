//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// This is a lightweight implementation of Observer design pattern. It is a simple Publisher - Subscriber mechanism,
/// where interested parties are registering closures to receive DomainEvents, and then other domain objects
/// publish events. Each subscriber is called on every publishing, in the order of subscription.
/// Publishing is asynchronous, meaning publish() calls within publish() calls will not be executed
/// in the same call stack but dispatched as a different sequential calls.
public class EventPublisher {

    private var subscriptions = [(subscriber: WeakWrapper, type: DomainEvent.Type, closure: (DomainEvent) -> Void)]()
    private var queue: OperationQueue

    public init () {
        queue = OperationQueue()
        queue.name = "EventPublisherSerialQueue"
        queue.maxConcurrentOperationCount = 1
    }

    public func subscribe<T>(_ subscriber: AnyObject, _ closure: @escaping (T) -> Void) where T: DomainEvent {
        subscriptions.append((WeakWrapper(subscriber), T.self, { c in closure(c as! T) }))
    }

    public func unsubscribe(_ subscriber: AnyObject) {
        subscriptions.removeAll { $0.subscriber.ref === subscriber }
    }

    public func publish(_ event: DomainEvent) {
        removeWeakNils()
        let subscriptionsSnapshot = subscriptions
        queue.addOperation {
            subscriptionsSnapshot
                .filter { $0.type == type(of: event) || $0.type == DomainEvent.self }
                .forEach { $0.closure(event) }
        }
    }

    private func removeWeakNils() {
        subscriptions = subscriptions.filter { $0.subscriber.ref != nil }
    }

}

open class DomainEvent {

    public init () {}

}
