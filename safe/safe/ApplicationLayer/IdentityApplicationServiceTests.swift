//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class IdentityApplicationServiceTests: SafeTestCase {

    func test_getOrCreateEOA_whenEOAIsThere_returnsExistingEOA() {
        let eoa1 = try! identityService.getOrCreateEOA()
        XCTAssertNotNil(eoa1)
        XCTAssertNotNil(eoa1.address)
        XCTAssertNotNil(eoa1.mnemonic)
        XCTAssertNotNil(eoa1.privateKey)
        XCTAssertNotNil(eoa1.publicKey)
        let eoa2 = try! identityService.getOrCreateEOA()
        XCTAssertEqual(eoa1, eoa2)
    }

    func test_getOrCreateEOA_throws() {
        let store = identityService.store as! MockSecureStore
        store.shouldThrow = true
        do {
            try _ = identityService.getOrCreateEOA()
            XCTFail("Should Throw")
        } catch let e {
            XCTAssertTrue(e is TestError)
        }
    }

    func test_getEOA_whenEOAIsThere_returnsExistingEOA() {
        XCTAssertNil(try! identityService.getEOA())
        let eoa1 = try! identityService.getOrCreateEOA()
        let eoa2 = try! identityService.getEOA()
        XCTAssertEqual(eoa1, eoa2)
    }

    func test_getEOA_throws() {
        let store = identityService.store as! MockSecureStore
        store.shouldThrow = true
        do {
            try _ = identityService.getEOA()
            XCTFail("Should Throw")
        } catch let e {
            XCTAssertTrue(e is TestError)
        }
    }

}
