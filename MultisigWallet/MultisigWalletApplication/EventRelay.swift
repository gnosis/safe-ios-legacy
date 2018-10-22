//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public protocol EventSubscriber: class {
    func notify()
}

/// Relays published events from EventPublisher to EventSubscribers.
/// When event subscriber is deallocated, it won't be notified again, therefore unsubscribing is optional.
public class EventRelay {

    private var subscribers = [(type: DomainEvent.Type, subscriber: WeakWrapper)]()

    public init(publisher: EventPublisher) {
        publisher.subscribe(self, handleEvent)
    }

    func subscribe(_ subject: EventSubscriber, for event: DomainEvent.Type) {
        subscribers.append((event, WeakWrapper(subject)))
    }

    func unsubscribe(_ subject: EventSubscriber) {
        if let index = subscribers.index(where: { $0.subscriber.ref === subject }) {
            subscribers.remove(at: index)
        }
    }

    private func handleEvent(_ event: DomainEvent) {
        removeWeakNils()
        subscribers.filter {
            $0.type == type(of: event) || $0.type == DomainEvent.self
        }.forEach {
            ($0.subscriber.ref as! EventSubscriber).notify()
        }
    }

    private func removeWeakNils() {
        subscribers = subscribers.filter { $0.subscriber.ref != nil }
    }

}
