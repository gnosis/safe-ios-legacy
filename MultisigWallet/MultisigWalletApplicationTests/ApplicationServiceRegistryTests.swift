//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel

class ApplicationServiceRegistryTests: EthereumApplicationTestCase {

    func test_services() {
        ApplicationServiceRegistry.put(service: MockEventRelay(publisher: MockEventPublisher()), for: EventRelay.self)
        XCTAssertNotNil(ApplicationServiceRegistry.ethereumService)
        XCTAssertNotNil(ApplicationServiceRegistry.eventRelay)
    }

}
