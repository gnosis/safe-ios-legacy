//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class AuthenticationPolicyTests: XCTestCase {

    func test_canCreate() {
        XCTAssertNotNil(try AuthenticationPolicy(duration: 5))
    }

    func test_durationMustBePositive() {
        XCTAssertThrowsError(try AuthenticationPolicy(duration: 0))
        XCTAssertThrowsError(try AuthenticationPolicy(duration: -1))
    }

}
