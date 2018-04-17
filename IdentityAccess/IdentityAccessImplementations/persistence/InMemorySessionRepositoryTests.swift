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

//    func test_whenSessionSaved_thenItCanBeFetched() throws {
//        let session = try XSession(id: repository.nextId(), durationInSeconds: 30)
//        try session.start(Date())
//        try repository.save(session)
//        let savedSession = repository.latestSession()
//        XCTAssertEqual(session, savedSession)
//    }
//
//    func test_whenConfigurationSaved_thenItCanBeFetched() throws {
//        let policy = try AuthenticationPolicy(sessionDuration: 5)
//        try repository.save(policy)
//        XCTAssertEqual(repository.authenticationPolicy(), policy)
//    }

}
