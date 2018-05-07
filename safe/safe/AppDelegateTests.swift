//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessImplementations
import IdentityAccessDomainModel
import SafeAppUI

class AppDelegateTests: XCTestCase {

    func test_createWindow() {
        let appDelegate = AppDelegate()
        _ = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        XCTAssertNotNil(appDelegate.window)
        XCTAssertNotNil(appDelegate.window?.rootViewController)
        XCTAssertTrue(appDelegate.window?.isKeyWindow ?? false)
    }

    func test_whenAppBecomesActive_thenCallsCoordinator() {
        let coordinator = MockCoordinator()
        let appDelegate = AppDelegate()
        appDelegate.coordinator = coordinator
        appDelegate.applicationWillEnterForeground(UIApplication.shared)
        XCTAssertTrue(coordinator.didBecomeActive)
    }

    func test_bundleHasRequiredProperties() {
        XCTAssertNotNil(Bundle.main.object(forInfoDictionaryKey: "NSFaceIDUsageDescription"))
    }

    func test_mainBundleContainsLoggerKeys() {
        XCTAssertNotNil(Bundle.main.object(forInfoDictionaryKey: LogServiceLogLevelKey))
        XCTAssertNotNil(Bundle.main.object(forInfoDictionaryKey: LogServiceEnabledLoggersKey))
    }

    func test_defaultValues() {
        XCTAssertNotNil(DomainRegistry.keyValueStore)
        XCTAssertNotNil(DomainRegistry.secureStore)
        XCTAssertNotNil(DomainRegistry.biometricAuthenticationService)
        XCTAssertNotNil(DomainRegistry.userRepository)
        XCTAssertNotNil(DomainRegistry.identityService)
        XCTAssertNotNil(DomainRegistry.gatekeeperRepository)
        XCTAssertNotNil(DomainRegistry.gatekeeperRepository.gatekeeper())
    }

}

class MockCoordinator: AppFlowCoordinatorProtocol {

    var didBecomeActive = false

    func appEntersForeground() {
        didBecomeActive = true
    }

    func startViewController() -> UIViewController {
        return UIViewController()
    }

}
