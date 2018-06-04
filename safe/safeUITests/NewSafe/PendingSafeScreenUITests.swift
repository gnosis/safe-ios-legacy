//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class PendingSafeScreenUITests: UITestCase {

    let mainScreen = MainScreen()

    func test_whenCreatingSafe_thenItSuccessful() {
        application.setMockServerResponseDelay(0)
        givenDeploymentStarted()
        waitUntil(mainScreen.addressLabel, timeout: 5, .exists)
    }

}
