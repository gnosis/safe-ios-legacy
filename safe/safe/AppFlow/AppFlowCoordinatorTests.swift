//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AppFlowCoordinatorTests: XCTestCase {

    var flowCoordinator: AppFlowCoordinator!
    let account = MockAccount()

    override func setUp() {
        super.setUp()
        flowCoordinator = AppFlowCoordinator(account: account)
    }

    func test_startViewController_whenPasswordWasNotSet_thenPresentingOnboarding() {
        account.hasMasterPassword = false
        let root = flowCoordinator.startViewController()
        XCTAssertTrue(type(of: root) == type(of: flowCoordinator.onboardingFlowCoordinator.startViewController()))
    }

    func test_whenUnlocked_thenShowsLockedController() {
        account.hasMasterPassword = true
        guard let unlockVC = flowCoordinator.startViewController() as? UnlockViewController else {
            XCTFail("Expecting unlock view controller")
            return
        }
        unlockVC.loadViewIfNeeded()
        account.shouldBiometryAuthenticationSuccess = true
        let anySender: Any = self
        unlockVC.loginWithBiometry(anySender)
        wait()
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            XCTFail("Root view controller not found")
            return
        }
        XCTAssertTrue(type(of: rootVC) == type(of: flowCoordinator.onboardingFlowCoordinator.startViewController()))
    }

}
