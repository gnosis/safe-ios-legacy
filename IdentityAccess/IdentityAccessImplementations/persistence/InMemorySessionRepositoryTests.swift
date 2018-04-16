//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel

class InMemorySessionRepositoryTests: XCTestCase {

    func test_whenSaved_retrievesSavedSession() throws {
        DomainRegistry.put(service: InMemorySessionRepository(), for: SessionRepository.self)
        let repository = DomainRegistry.sessionRepository
        let session = try XSession(id: repository.nextId(), durationInSeconds: 30)
        try session.start(Date())
        try repository.save(session)
        let savedSession = repository.latestSession()
        XCTAssertEqual(session, savedSession)
    }

}
