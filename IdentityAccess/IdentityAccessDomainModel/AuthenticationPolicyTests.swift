//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class AuthenticationPolicyTests: XCTestCase {

    func test_canCreate() {
        XCTAssertNotNil(try AuthenticationPolicy(sessionDuration: 5))
    }

    func test_durationMustBePositive() {
        XCTAssertThrowsError(try AuthenticationPolicy(sessionDuration: 0))
        XCTAssertThrowsError(try AuthenticationPolicy(sessionDuration: -1))
    }

}
