//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class RemoveSafeFlowCoordinatorTests: XCTestCase {

    var removeSafeCoordinator: RemoveSafeFlowCoordinator!

    var topViewController: UIViewController? {
        return removeSafeCoordinator.navigationController.topViewController
    }

    override func setUp() {
        super.setUp()
        removeSafeCoordinator = RemoveSafeFlowCoordinator(rootViewController: UINavigationController())
        removeSafeCoordinator.safeAddress = ""
        removeSafeCoordinator.setUp()
    }

    func test_startViewController_returnsRemoveSafeIntroVC() {
        XCTAssertTrue(topViewController is RemoveSafeIntroViewController)
    }

    func test_whenNavigatingNextFromIntro_thenPushedEnterSeedVC() {
        let removeSafeVC = topViewController as! RemoveSafeIntroViewController
        removeSafeVC.loadView()
        removeSafeVC.viewDidLoad()
        removeSafeVC.footerButton.sendActions(for: .touchUpInside)
        delay()
        XCTAssertTrue(topViewController is RecoveryPhraseInputViewController)
    }

}
