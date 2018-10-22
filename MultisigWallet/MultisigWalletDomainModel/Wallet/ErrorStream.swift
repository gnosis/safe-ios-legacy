//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Serves to be a sink for errors occuring during different operations or as a result of processing DomainEvents.
/// ErrorStream accumulates errors and forwards them to subscribers. This is very similar to EventPublisher, but
/// here the Error is published (posted), so that other parties could handle it or log it.
public class ErrorStream {

    private var handlers = [(handler: WeakWrapper, closure: (Error) -> Void)]()
    private var queue: OperationQueue

    public init () {
        queue = OperationQueue()
        queue.name = "ErrorStreamSerialQueue"
        queue.maxConcurrentOperationCount = 1
    }

    public func post(_ error: Error) {
        removeWeakNils()
        let snapshotHandlers = handlers
        queue.addOperation {
            snapshotHandlers.forEach { $0.closure(error) }
        }
    }

    private func removeWeakNils() {
        handlers = handlers.filter { $0.handler.ref != nil }
    }

    public func addHandler(_ handler: AnyObject, _ closure: @escaping (Error) -> Void) {
        handlers.append((WeakWrapper(handler), closure))
    }

    public func removeHandler(_ handler: AnyObject) {
        handlers.removeAll { $0.handler.ref === handler }
    }

}
