//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AppFlowCoordinatorTests: AbstractAppTestCase {

    var flowCoordinator = AppFlowCoordinator()
    let password = "MyPassword"

    override func setUp() {
        super.setUp()
        try? authenticationService.registerUser(password: password)
    }

    func test_startViewController_whenUserNotRegistered_thenPresentingOnboarding() {
        authenticationService.unregisterUser()
        let root = flowCoordinator.startViewController()
        XCTAssertTrue(type(of: root) == type(of: flowCoordinator.onboardingFlowCoordinator.startViewController()))
    }

    func test_whenStartingAppAndAlreadyRegistered_thenIgnoresSessionStateAndShowsLockedController() {
        authenticationService.authenticateUser(password: password)
        guard let rootVC = rootViewControlleOnAppStartrAfterUnlocking() else { return }
        XCTAssertTrue(type(of: rootVC) == type(of: flowCoordinator.onboardingFlowCoordinator.startViewController()))
    }

    func test_whenAuthenticationInvalidated_thenLocks() {
        authenticationService.invalidateAuthentication()
        XCTAssertTrue(flowCoordinator.startViewController() is UnlockViewController)
    }

    func test_whenAppBecomesActiveAndNotAuthenticated_thenLocks() {
        authenticationService.invalidateAuthentication()

        let securedVC = UIViewController()
        UIApplication.rootViewController = securedVC
        flowCoordinator.appEntersForeground()
        guard let rootVC = UIApplication.rootViewController else {
            XCTFail("Expected to have root view controller")
            return
        }
        XCTAssertFalse(rootVC === securedVC)
        XCTAssertTrue(rootVC is UnlockViewController)

        authenticationService.allowAuthentication()
        let anySender: Any = self
        (rootVC as? UnlockViewController)?.loginWithBiometry(anySender)
        delay()
        XCTAssertTrue(UIApplication.rootViewController === securedVC)
    }

    func test_whenAppIsLockedAndBecomesActive_thenDoesntLockTwice() {
        authenticationService.invalidateAuthentication()
        XCTAssertFalse(rootViewControlleOnAppStartrAfterUnlocking() is UnlockViewController)
    }

    func test_whenAppBecomesActiveAndAlreadyAuthenticated_thenDoesntLock() {
        authenticationService.allowAuthentication()
        authenticationService.authenticateUser(password: password)
        XCTAssertTrue(isUnlockedAfterBecomingActive())
    }

    func test_whenAppBecomesActiveButNotRegistered_thenDoesNotLock() {
        authenticationService.unregisterUser()
        XCTAssertTrue(isUnlockedAfterBecomingActive())
    }

}

extension AppFlowCoordinatorTests {

    private func rootViewControlleOnAppStartrAfterUnlocking() -> UIViewController? {
        guard let unlockVC = flowCoordinator.startViewController() as? UnlockViewController else {
            XCTFail("Expecting unlock view controller")
            return nil
        }
        UIApplication.rootViewController = unlockVC
        authenticationService.allowAuthentication()
        let anySender: Any = self
        unlockVC.loginWithBiometry(anySender)
        delay()
        guard let rootVC = UIApplication.rootViewController else {
            XCTFail("Root view controller not found")
            return nil
        }
        return rootVC
    }

    private func isUnlockedAfterBecomingActive() -> Bool {
        let securedVC = UIViewController()
        UIApplication.rootViewController = securedVC
        flowCoordinator.appEntersForeground()
        guard let rootVC = UIApplication.rootViewController else {
            XCTFail("Expected to have root view controller")
            return false
        }
        return rootVC === securedVC
    }
}
