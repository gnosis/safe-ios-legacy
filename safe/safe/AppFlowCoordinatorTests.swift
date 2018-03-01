//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AppFlowCoordinatorTests: XCTestCase {

    func test_createWindow() {
        let fc = AppFlowCoordinator()
        let window = fc.createWindow()
        guard let root = window.rootViewController else {
            XCTFail()
            return
        }
        XCTAssertTrue(type(of: root) == type(of: fc.onboardingFlowCoordinator.startViewController()))
    }

}
