//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
import IdentityAccessDomainModel
import CommonTestSupport
import IdentityAccessImplementations

class IdentityApplicationServiceTests: ApplicationServiceTestCase {

    let secureStore = InMemorySecureStore()
    let keyValueStore = InMemoryKeyValueStore()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: secureStore, for: SecureStore.self)
        DomainRegistry.put(service: EncryptionService(), for: EncryptionServiceProtocol.self)
        DomainRegistry.put(service: keyValueStore, for: KeyValueStore.self)
        cleanup()
    }

    private func cleanup() {
        keyValueStore.deleteKey(UserDefaultsKey.isRecoveryOptionSet.rawValue)
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

    func test_getEOA_whenEOAIsThere_returnsExistingEOA() throws {
        XCTAssertNil(try identityService.getEOA())
        let eoa1 = try identityService.getOrCreateEOA()
        let eoa2 = try identityService.getEOA()
        XCTAssertEqual(eoa1, eoa2)
    }

    func test_getEOA_throws() {
        secureStore.shouldThrow = true
        do {
            try _ = identityService.getEOA()
            XCTFail("Should Throw")
        } catch let e {
            XCTAssertTrue(e is TestError)
        }
    }

    func test_isRecoverySet() {
        XCTAssertFalse(identityService.isRecoverySet)
        keyValueStore.setBool(true, for: UserDefaultsKey.isRecoveryOptionSet.rawValue)
        XCTAssertTrue(identityService.isRecoverySet)
    }

}
