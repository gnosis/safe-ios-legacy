//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class FeeIntroViewControllerTests: SafeTestCase {

    var controller: FeeIntroViewController!

    override func setUp() {
        super.setUp()
        controller = FeeIntroViewController()
    }

    func test_whenCreated_thenFetchesEstimationData() {
        controller.viewDidLoad()
        delay()
        XCTAssertTrue(walletService.didCallEstimateSafeCreation)
    }

}
