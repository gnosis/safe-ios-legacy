//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

public protocol EventSubscriber: class {
    func notify()
}

/// Relays published events from EventPublisher to EventSubscribers.
/// When event subscriber is deallocated, it won't be notified again, therefore unsubscribing is optional.
public class EventRelay {

    private var subscribers = [(type: DomainEvent.Type, subscriber: WeakWrapper)]()
    private var queue: DispatchQueue

    public init(publisher: EventPublisher) {
        queue = DispatchQueue(label: "io.gnosis.safe.EventRelay",
                              qos: .userInitiated,
                              attributes: [])
        publisher.subscribe(self) { [unowned self] event in
            self.handleEvent(event)
        }
    }

    func subscribe(_ subject: EventSubscriber, for event: DomainEvent.Type) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            self.subscribers.append((event, WeakWrapper(subject)))
            self.removeWeakNils()
        }
    }

    // TODO: make thread safe
    func unsubscribe(_ subject: EventSubscriber) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            if let index = self.subscribers.firstIndex(where: { $0.subscriber.ref === subject }) {
                self.subscribers.remove(at: index)
            }
            self.removeWeakNils()
        }
    }

    private func handleEvent(_ event: DomainEvent) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            self.removeWeakNils()
            self.subscribers.filter {
                $0.type == type(of: event) || $0.type == DomainEvent.self
            }.forEach {
                // unwrapped optional because the subscriber's ref might nil out on a different thread.
                ($0.subscriber.ref as? EventSubscriber)?.notify()
            }
        }

    }

    private func removeWeakNils() {
        dispatchPrecondition(condition: .onQueue(queue))
        subscribers = subscribers.filter { $0.subscriber.ref != nil }
    }

}
