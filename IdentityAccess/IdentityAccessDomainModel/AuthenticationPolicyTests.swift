//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class AuthenticationPolicyTests: XCTestCase {

    func test_durationMustBePositive() {
        let s: TimeInterval = 1, a: Int = 1, b: TimeInterval = 1
        XCTAssertThrowsError(try AuthenticationPolicy(sessionDuration: -1, maxFailedAttempts: a, blockDuration: b))
        XCTAssertThrowsError(try AuthenticationPolicy(sessionDuration: 0, maxFailedAttempts: a, blockDuration: b))
        XCTAssertNoThrow(try AuthenticationPolicy(sessionDuration: 1, maxFailedAttempts: a, blockDuration: b))

        XCTAssertThrowsError(try AuthenticationPolicy(sessionDuration: s, maxFailedAttempts: 0, blockDuration: b))
        XCTAssertThrowsError(try AuthenticationPolicy(sessionDuration: s, maxFailedAttempts: -1, blockDuration: b))
        XCTAssertNoThrow(try AuthenticationPolicy(sessionDuration: s, maxFailedAttempts: 1, blockDuration: b))

        XCTAssertThrowsError(try AuthenticationPolicy(sessionDuration: s, maxFailedAttempts: a, blockDuration: -1))
        XCTAssertNoThrow(try AuthenticationPolicy(sessionDuration: s, maxFailedAttempts: a, blockDuration: 0))
        XCTAssertNoThrow(try AuthenticationPolicy(sessionDuration: s, maxFailedAttempts: a, blockDuration: 1))
    }

}
