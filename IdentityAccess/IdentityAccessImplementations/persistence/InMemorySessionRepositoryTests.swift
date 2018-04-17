//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel

class InMemorySessionRepositoryTests: XCTestCase {

    let repository: GatekeeperRepository = InMemoryGatekeeperRepository()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: repository, for: GatekeeperRepository.self)
    }


}
