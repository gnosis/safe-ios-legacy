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
class EventRelay {

    private class SubscriberWrapper {
        weak var ref: EventSubscriber?

        init(_ ref: EventSubscriber) {
            self.ref = ref
        }
    }

    private var subscribers = [(type: DomainEvent.Type, subscriber: SubscriberWrapper)]()

    init(publisher: EventPublisher) {
        publisher.subscribe(handleEvent)
    }

    func subscribe(_ subject: EventSubscriber, for event: DomainEvent.Type) {
        subscribers.append((event, SubscriberWrapper(subject)))
    }

    func unsubscribe(_ subject: EventSubscriber) {
        if let index = subscribers.index(where: { $0.subscriber.ref === subject }) {
            subscribers.remove(at: index)
        }
    }

    func reset(publisher: EventPublisher) {
        subscribers = []
        publisher.subscribe(handleEvent)
    }

    private func handleEvent(_ event: DomainEvent) {
        subscribers = subscribers.filter { $0.subscriber.ref != nil }
        subscribers.filter {
            $0.type == type(of: event) || $0.type == DomainEvent.self
        }.forEach {
            $0.subscriber.ref!.notify()
        }
    }

}
