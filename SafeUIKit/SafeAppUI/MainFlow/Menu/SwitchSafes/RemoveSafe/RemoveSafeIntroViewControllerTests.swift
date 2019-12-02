//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import MultisigWalletApplication

class RemoveSafeIntroViewControllerTests: XCTestCase {

    var controller: RemoveSafeIntroViewController!
    var didPressNext = false

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: MockWalletApplicationService(),
                                       for: WalletApplicationService.self)
        controller = RemoveSafeIntroViewController.create(walletID: "") { [unowned self] in
            self.didPressNext = true
        }
        controller.loadView()
    }

    func test_tracking() {
        controller.viewDidAppear(false)
        XCTAssertTracksAppearance(in: controller, SafesTrackingEvent.removeSafeIntro)
    }

}
