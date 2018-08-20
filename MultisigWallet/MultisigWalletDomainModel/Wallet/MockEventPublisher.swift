//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class MockEventPublisher: EventPublisher {

    private var filteredEventTypes = [String]()

    func addFilter(_ event: Any.Type) {
        filteredEventTypes.append(String(reflecting: event))
    }

    override func publish(_ event: DomainEvent) {
        guard filteredEventTypes.isEmpty || filteredEventTypes.contains(String(reflecting: type(of: event))) else {
            return
        }
        super.publish(event)
    }

}
