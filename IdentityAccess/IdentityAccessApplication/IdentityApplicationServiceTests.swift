//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import IdentityAccessDomainModel
import CommonTestSupport
import IdentityAccessImplementations

class IdentityApplicationServiceTests: ApplicationServiceTestCase {

    let store = MockSecureStore()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: store, for: SecureStore.self)
        DomainRegistry.put(service: EncryptionService(), for: EncryptionServiceProtocol.self)
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
        store.shouldThrow = true
        do {
            try _ = identityService.getOrCreateEOA()
            XCTFail("Should Throw")
        } catch let e {
            XCTAssertTrue(e is TestError)
        }
    }

    func test_getEOA_whenEOAIsThere_returnsExistingEOA() throws {
        XCTAssertNil(try identityService.getEOA())
        let eoa1 = try identityService.getOrCreateEOA()
        let eoa2 = try identityService.getEOA()
        XCTAssertEqual(eoa1, eoa2)
    }

    func test_getEOA_throws() {
        store.shouldThrow = true
        do {
            try _ = identityService.getEOA()
            XCTFail("Should Throw")
        } catch let e {
            XCTAssertTrue(e is TestError)
        }
    }

}
