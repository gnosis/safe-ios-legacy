//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Serves to be a sink for errors occuring during different operations or as a result of processing DomainEvents.
/// ErrorStream accumulates errors and forwards them to subscribers. This is very similar to EventPublisher, but
/// here the Error is published (posted), so that other parties could handle it or log it.
public class ErrorStream {

    private var handlers = [(handler: WeakWrapper, closure: (Error) -> Void)]()
    private var queue = DispatchQueue(label: "io.gnosis.safe.ErrorStream")

    public init () {}

    public func post(_ error: Error) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            self.removeWeakNils()
            self.handlers.forEach { $0.closure(error) }
        }
    }

    private func removeWeakNils() {
        dispatchPrecondition(condition: .onQueue(queue))
        handlers = handlers.filter { $0.handler.ref != nil }
    }

    public func addHandler(_ handler: AnyObject, _ closure: @escaping (Error) -> Void) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            self.handlers.append((WeakWrapper(handler), closure))
        }
    }

    public func removeHandler(_ handler: AnyObject) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            self.handlers.removeAll { $0.handler.ref === handler }
        }
    }

}
