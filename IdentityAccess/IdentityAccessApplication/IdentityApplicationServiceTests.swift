//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import IdentityAccessDomainModel
import CommonTestSupport
import IdentityAccessImplementations
@testable import IdentityAccessApplication

class IdentityApplicationServiceTests: ApplicationServiceTestCase {

    let secureStore = InMemorySecureStore()
    let keyValueStore = InMemoryKeyValueStore()

    override func setUp() {
        super.setUp()
        DraftSafe.shared = nil
        DomainRegistry.put(service: secureStore, for: SecureStore.self)
        DomainRegistry.put(service: EncryptionService(), for: EncryptionServiceProtocol.self)
        DomainRegistry.put(service: keyValueStore, for: KeyValueStore.self)
    }

    func test_getOrCreateEOA_whenEOAIsThere_returnsExistingEOA() throws {
        let eoa1 = try identityService.getOrCreateEOA()
        XCTAssertNotNil(eoa1)
        XCTAssertNotNil(eoa1.address)
        XCTAssertNotNil(eoa1.mnemonic)
        XCTAssertNotNil(eoa1.privateKey)
        XCTAssertNotNil(eoa1.publicKey)
        let eoa2 = try identityService.getOrCreateEOA()
        XCTAssertEqual(eoa1, eoa2)
    }

    func test_getOrCreateEOA_throws() {
        secureStore.shouldThrow = true
        do {
            try _ = identityService.getOrCreateEOA()
            XCTFail("Should Throw")
        } catch let e {
            XCTAssertTrue(e is TestError)
        }
    }

    func test_getOrCreateDraftSafe_returnsExistingDraftSafe() throws {
        XCTAssertNil(DraftSafe.shared)
        let ds1 = try identityService.getOrCreateDraftSafe()
        XCTAssertNotNil(DraftSafe.shared)
        let ds2 = try identityService.getOrCreateDraftSafe()
        XCTAssertTrue(ds1 === ds2)
    }

}
