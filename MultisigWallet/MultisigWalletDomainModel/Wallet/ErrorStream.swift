//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Serves to be a sink for errors occuring during different operations or as a result of processing DomainEvents.
/// ErrorStream accumulates errors and forwards them to subscribers. This is very similar to EventPublisher, but
/// here the Error is published (posted), so that other parties could handle it or log it.
public class ErrorStream {

    private var handlers = [(Error) -> Void]()

    public init () {}

    public func post(_ error: Error) {
        handlers.forEach { $0(error) }
    }

    public func addHandler(_ handler: @escaping (Error) -> Void) {
        handlers.append(handler)
    }

    public func reset() {
        handlers = []
    }
}
