//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import CommonTestSupport

class RecoveryWithMnemonicFlowCoordinatorTests: XCTestCase {

    let flowCoordinator = RecoveryWithMnemonicFlowCoordinator()
    var nav = UINavigationController()

    override func setUp() {
        super.setUp()
        let startVC = flowCoordinator.startViewController(parent: nav)
        nav.pushViewController(startVC, animated: false)
    }

    func test_startViewController_createsSaveMnemonicViewControllerWithDelegate() {
        XCTAssertTrue(nav.topViewController is SaveMnemonicViewController)
        let controller = nav.topViewController as! SaveMnemonicViewController
        XCTAssertTrue(controller.delegate === flowCoordinator)
    }

    func test_didPressContinue_pushesConfirmMnemonicViewController() {
        flowCoordinator.didPressContinue()
        delay()
        XCTAssertTrue(nav.topViewController is ConfirmMnemonicViewController)
    }

}
