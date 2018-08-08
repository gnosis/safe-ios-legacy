//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel

class InMemoryGatekeeperRepositoryTests: XCTestCase {

    let repository: SingleGatekeeperRepository = InMemoryGatekeeperRepository()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: repository, for: SingleGatekeeperRepository.self)
    }

    func test_saveFetch() throws {
        let policy = try AuthenticationPolicy(sessionDuration: 1, maxFailedAttempts: 1, blockDuration: 1)
        let gatekeeper = Gatekeeper(id: repository.nextId(), policy: policy)
        try repository.save(gatekeeper)
        XCTAssertEqual(repository.gatekeeper(), gatekeeper)
    }

    func test_remove() throws {
        let policy = try AuthenticationPolicy(sessionDuration: 1, maxFailedAttempts: 1, blockDuration: 1)
        let gatekeeper = Gatekeeper(id: repository.nextId(), policy: policy)
        try repository.save(gatekeeper)
        try repository.remove(gatekeeper)
        XCTAssertNil(repository.gatekeeper())
    }

}
