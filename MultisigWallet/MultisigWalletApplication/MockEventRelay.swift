//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import MultisigWalletDomainModel
@testable import MultisigWalletApplication

class MockEventRelay: EventRelay {

    private var expected_reset = [String]()
    private var actual_reset = [String]()

    public func expect_reset() {
        expected_reset.append("reset(publisher:)")
    }

    public override func reset(publisher: EventPublisher) {
        actual_reset.append(#function)
    }

    public func verify() -> Bool {
        return actual_reset == expected_reset
    }

}
