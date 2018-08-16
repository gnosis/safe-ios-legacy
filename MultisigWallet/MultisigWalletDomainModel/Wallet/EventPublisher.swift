//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

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

}

public class DomainEvent {

    public init () {}

}
