//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Serves to be a sink for errors occuring during different operations or as a result of processing DomainEvents.
/// ErrorStream accumulates errors and forwards them to subscribers. This is very similar to EventPublisher, but
/// here the Error is published (posted), so that other parties could handle it or log it.
public class ErrorStream {

    public init () {}

    public func post(_ error: Error) {}

}
