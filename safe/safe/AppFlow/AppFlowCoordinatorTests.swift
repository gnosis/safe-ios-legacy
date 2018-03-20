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

    func test_whenStartingAppAndHasPassword_thenIgnoresSessionStateAndShowsLockedController() {
        account.hasMasterPassword = true
        account.isSessionActive = true
        guard let rootVC = rootViewControlleOnAppStartrAfterUnlocking() else { return }
        XCTAssertTrue(type(of: rootVC) == type(of: flowCoordinator.onboardingFlowCoordinator.startViewController()))
    }

    func test_whenSessionExpires_thenLocks() {
        account.isSessionActive = false
        account.hasMasterPassword = true
        XCTAssertTrue(flowCoordinator.startViewController() is UnlockViewController)
    }

    func test_whenAppBecomesActiveAndSessionExpires_thenLocks() {
        account.hasMasterPassword = true
        account.isSessionActive = false
        let securedVC = UIViewController()
        UIApplication.rootViewController = securedVC
        flowCoordinator.appEntersForeground()
        guard let rootVC = UIApplication.rootViewController else {
            XCTFail("Expected to have root view controller")
            return
        }
        XCTAssertFalse(rootVC === securedVC)
        XCTAssertTrue(rootVC is UnlockViewController)
        let anySender: Any = self
        (rootVC as? UnlockViewController)?.loginWithBiometry(anySender)
        delay()
        XCTAssertTrue(UIApplication.rootViewController === securedVC)
    }

    func test_whenAppIsLockedAndBecomesActive_thenDoesntLockTwice() {
        account.hasMasterPassword = true
        account.isSessionActive = false
        XCTAssertFalse(rootViewControlleOnAppStartrAfterUnlocking() is UnlockViewController)
    }

    func test_whenAppBecomesActiveAndSessionIsActive_thenDoesntLock() {
        account.hasMasterPassword = true
        account.isSessionActive = true
        assertThatUnlockedAfterBecomingActive()
    }

    func test_whenAppBecomesActiveButNoMasterPasswordSet_thenDoesNotLock() {
        account.hasMasterPassword = false
        account.isSessionActive = false
        assertThatUnlockedAfterBecomingActive()
    }

}

extension AppFlowCoordinatorTests {

    private func rootViewControlleOnAppStartrAfterUnlocking() -> UIViewController? {
        guard let unlockVC = flowCoordinator.startViewController() as? UnlockViewController else {
            XCTFail("Expecting unlock view controller")
            return nil
        }
        UIApplication.rootViewController = unlockVC
        account.shouldBiometryAuthenticationSuccess = true
        let anySender: Any = self
        unlockVC.loginWithBiometry(anySender)
        delay()
        guard let rootVC = UIApplication.rootViewController else {
            XCTFail("Root view controller not found")
            return nil
        }
        return rootVC
    }

    private func assertThatUnlockedAfterBecomingActive() {
        let securedVC = UIViewController()
        UIApplication.rootViewController = securedVC
        flowCoordinator.appEntersForeground()
        guard let rootVC = UIApplication.rootViewController else {
            XCTFail("Expected to have root view controller")
            return
        }
        XCTAssertTrue(rootVC === securedVC)
    }
}
