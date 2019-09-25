//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class RemoveSafeEnterSeedViewControllerTests: XCTestCase {

    let controller = RemoveSafeEnterSeedViewController()

    func test_tracking() {
        controller.viewDidAppear(false)
        XCTAssertTracksAppearance(in: controller, SafesTrackingEvent.removeSafeEnterSeed)
    }

}
