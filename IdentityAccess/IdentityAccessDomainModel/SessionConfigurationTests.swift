//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class SessionConfigurationTests: XCTestCase {

    func test_canCreate() {
        XCTAssertNotNil(try SessionConfiguration(duration: 5))
    }

    func test_durationMustBePositive() {
        XCTAssertThrowsError(try SessionConfiguration(duration: 0))
        XCTAssertThrowsError(try SessionConfiguration(duration: -1))
    }

}
