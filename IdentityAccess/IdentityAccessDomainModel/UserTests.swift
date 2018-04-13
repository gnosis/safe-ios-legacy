//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class UserTests: DomainTestCase {

    let id = UserID("ID")

    func test_create_passwordNotEmpty() {
        XCTAssertThrowsError(try create(password: "")) {
            self.assertError($0, .emptyPassword)
        }
    }

    func test_create_passwordNSymbols() {
        let short = String(repeating: "1", count: 5)
        let long = String(repeating: "1", count: 101)
        XCTAssertThrowsError(try create(password: short)) {
            self.assertError($0, .passwordTooShort)
        }
        XCTAssertThrowsError(try create(password: long)) {
            self.assertError($0, .passwordTooLong)
        }
    }

    func test_create_passwordCapitalLetter() {
        XCTAssertThrowsError(try create(password: "123456")) {
            self.assertError($0, .passwordMissingCapitalLetter)
        }
    }

    func test_create_digit() {
        XCTAssertThrowsError(try create(password: "abcabC")) {
            self.assertError($0, .passwordMissingDigit)
        }
    }

}

extension UserTests {

    func create(password: String) throws -> User {
        return try User(id: id, password: password)
    }

    func assertError(_ error: Error, _ expected: User.Error) {
        XCTAssertEqual(error as? User.Error, expected)
    }
}
