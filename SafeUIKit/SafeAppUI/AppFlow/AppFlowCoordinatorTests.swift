//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import Common

class AppFlowCoordinatorTests: SafeTestCase {

    var flowCoordinator: AppFlowCoordinator!
    let password = "MyPassword"

    override func setUp() {
        super.setUp()
        try? authenticationService.registerUser(password: password)
        createFlowCoordinator()
    }

    func test_startViewController_whenUserNotRegistered_thenPresentingOnboarding() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: OnboardingFlowCoordinator())
        let expectedController = testFC.topViewController

        authenticationService.unregisterUser()
        createFlowCoordinator()
        XCTAssertTrue(type(of: flowCoordinator.navigationController.topViewController) == type(of: expectedController))
    }

    func test_whenStartingAppAndAlreadyRegistered_thenIgnoresSessionStateAndShowsLockedController() throws {
        _ = try authenticationService.authenticateUser(.password(password))
        createFlowCoordinator()
        guard let rootVC = rootViewControlleOnAppStartrAfterUnlocking() else {
            XCTFail()
            return
        }
        let typeA = type(of: rootVC)
        let typeB = type(of: flowCoordinator.rootViewController!)
        XCTAssertTrue(typeA == typeB)
    }

    func test_whenAuthenticationInvalidated_thenLocks() {
        authenticationService.invalidateAuthentication()
        createFlowCoordinator()
        XCTAssertTrue(UIApplication.rootViewController is UnlockViewController)
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
        createFlowCoordinator()
        XCTAssertFalse(rootViewControlleOnAppStartrAfterUnlocking() is UnlockViewController)
    }

    func test_whenAppBecomesActiveAndAlreadyAuthenticated_thenDoesntLock() throws {
        authenticationService.allowAuthentication()
        _ = try Authenticator.instance.authenticate(.password(password))
        XCTAssertTrue(isUnlockedAfterBecomingActive())
    }

    func test_whenAppBecomesActiveButNotRegistered_thenDoesNotLock() {
        authenticationService.unregisterUser()
        XCTAssertTrue(isUnlockedAfterBecomingActive())
    }

    func test_whenSelectedWalletIsReady_thenShowsMainScreen() throws {
        authenticationService.allowAuthentication()
        _ = try Authenticator.instance.authenticate(.password(password))
        walletService.createReadyToUseWallet()
        createFlowCoordinator()
        XCTAssertTrue((rootViewControlleOnAppStartrAfterUnlocking() as? UINavigationController)?.topViewController
            is MainViewController)
    }

    func test_whenOnboardingFlowExits_thenEntersMainScreen() throws {
        authenticationService.allowAuthentication()
        _ = try Authenticator.instance.authenticate(.password(password))
        walletService.createNewDraftWallet()
        walletService.update(account: ethID, newBalance: 100)
        walletService.assignAddress("address")
        createFlowCoordinator()
        guard let rootVC = rootViewControlleOnAppStartrAfterUnlocking() else {
            XCTFail()
            return
        }
        XCTAssertTrue(type(of: flowCoordinator.onboardingFlowCoordinator.rootViewController!) == type(of: rootVC))
        flowCoordinator.onboardingFlowCoordinator.exitFlow()
        XCTAssertTrue((UIApplication.rootViewController as? UINavigationController)?.topViewController
            is MainViewController)
    }

    func test_whenReceivingRemoteMessage_delegatesToMainFlowCoordinator() {
        flowCoordinator.receive(message: ["key": "value"])
        XCTAssertNotNil(walletService.receive_input)
    }

}

extension AppFlowCoordinatorTests {

    private func createFlowCoordinator() {
        flowCoordinator = AppFlowCoordinator()
        flowCoordinator.setUp()
    }

    private func rootViewControlleOnAppStartrAfterUnlocking() -> UIViewController? {
        guard let unlockVC = UIApplication.rootViewController as? UnlockViewController else {
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
