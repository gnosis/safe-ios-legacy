//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import CommonTestSupport

class NewSafeFlowCoordinatorTests: SafeTestCase {

    let newSafeFlowCoordinator = NewSafeFlowCoordinator()
    let nav = UINavigationController()

    override func setUp() {
        super.setUp()
        let startVC = newSafeFlowCoordinator.startViewController(parent: nav)
        nav.pushViewController(startVC, animated: false)
    }

    func test_startViewController_returnsSetupSafeStartVC() {
        XCTAssertTrue(nav.topViewController is NewSafeViewController)
    }

    func test_didSelectMnemonicRecovery_showsRecoveryWithMnemonicFlowCoordinatorStartVC() {
        newSafeFlowCoordinator.didSelectPaperWalletSetup()
        delay()
        let fc = PaperWalletFlowCoordinator()
        let startVC = fc.startViewController(parent: newSafeFlowCoordinator.rootVC)
        XCTAssertTrue(type(of: nav.topViewController!) == type(of: startVC))
    }

}
