//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class KeychainServiceIntegrationTests: XCTestCase {

    let service = KeychainService(identifier: "KeychainIntegrationTest")
    let correctPassword = "Password"

    override func setUp() {
        super.setUp()
        do {
            try service.removePassword()
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

    func test_password_whenNotSet_returnsNil() {
        do {
            let password = try service.password()
            XCTAssertNil(password)
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

    func test_whenPasswordSaved_thenPasswordReturnsIt() {
        do {
            try service.savePassword(correctPassword)
            let password = try service.password()
            XCTAssertEqual(password, correctPassword)
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

    func test_whenPasswordRemoved_thenPasswordReturnsNil() {
        do {
            try service.savePassword(correctPassword)
            try service.removePassword()
            let password = try service.password()
            XCTAssertNil(password)
        } catch let e {
            XCTFail("Failed: \(e)")
        }
    }

}
