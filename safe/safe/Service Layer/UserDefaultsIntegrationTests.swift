//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class UserDefaultsIntegrationTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        saveCurrentUserDefaults()
    }

    override class func tearDown() {
        super.setUp()
        restoreUserDefaults()
    }

    class func saveCurrentUserDefaults() {
        // save values to a variable
    }

    class func restoreUserDefaults() {
        // clean up all defaults
        // restore to saved values
    }

    func test_whenCondition_thenResult() {
    }

}
