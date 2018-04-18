//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class UserTests: DomainTestCase {

    var id: UserID!
    let password = "123456A"

    override func setUp() {
        super.setUp()
        id = userRepository.nextId()
    }

    func test_create_passwordNotEmpty() {
        XCTAssertThrowsError(try createUser(password: "")) {
            self.assertError($0, .emptyPassword)
        }
    }

    func test_create_passwordNSymbols() {
        let short = String(repeating: "1", count: 5)
        let long = String(repeating: "1", count: 101)
        XCTAssertThrowsError(try createUser(password: short)) {
            self.assertError($0, .passwordTooShort)
        }
        XCTAssertThrowsError(try createUser(password: long)) {
            self.assertError($0, .passwordTooLong)
        }
    }

    func test_create_passwordCapitalLetter() {
        XCTAssertThrowsError(try createUser(password: "123456")) {
            self.assertError($0, .passwordMissingCapitalLetter)
        }
    }

    func test_create_digit() {
        XCTAssertThrowsError(try createUser(password: "abcabC")) {
            self.assertError($0, .passwordMissingDigit)
        }
    }

    func test_create_idLength() {
        XCTAssertThrowsError(try UserID("ID")) {
            XCTAssertEqual($0 as? UserID.Error, .invalidID)
        }
    }

}

extension UserTests {

    func createUser(password: String) throws -> User {
        return try User(id: id, password: password)
    }

    func assertError(_ error: Error, _ expected: User.Error) {
        XCTAssertEqual(error as? User.Error, expected)
    }
}
