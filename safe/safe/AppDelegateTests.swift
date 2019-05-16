//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessImplementations
import IdentityAccessDomainModel
import SafeAppUI
import CommonImplementations
import CommonTestSupport
import MultisigWalletDomainModel
import MultisigWalletImplementations

class AppDelegateTests: XCTestCase {

    // swiftlint:disable:next weak_delegate
    let appDelegate = AppDelegate()
    let mockSyncService = MockSynchronisationService()

    override func setUp() {
        super.setUp()
        MultisigWalletDomainModel.DomainRegistry.put(service: mockSyncService, for: SynchronisationDomainService.self)
    }

    func test_whenAppBecomesActive_thenCallsCoordinator() {
        let coordinator = MockCoordinator()
        appDelegate.coordinator = coordinator
        appDelegate.applicationWillEnterForeground(UIApplication.shared)
        XCTAssertTrue(coordinator.didBecomeActive)
    }

    func test_whenAppBecomesActive_thenSyncronises() {
        appDelegate.applicationDidBecomeActive(UIApplication.shared)
        XCTAssertTrue(mockSyncService.didStart)
    }

    func test_whenEnteringBackground_thenStopsSync() {
        appDelegate.applicationDidEnterBackground(UIApplication.shared)
        XCTAssertTrue(mockSyncService.didStop)
    }

    func test_bundleHasRequiredProperties() {
        XCTAssertNotNil(Bundle.main.object(forInfoDictionaryKey: "NSFaceIDUsageDescription"))
    }

    func test_mainBundleContainsLoggerKeys() {
        XCTAssertNotNil(Bundle.main.object(forInfoDictionaryKey: LogServiceLogLevelKey))
        XCTAssertNotNil(Bundle.main.object(forInfoDictionaryKey: LogServiceEnabledLoggersKey))
    }

    func test_defaultValues() {
        XCTAssertNotNil(DomainRegistry.biometricAuthenticationService)
        XCTAssertNotNil(DomainRegistry.userRepository)
        XCTAssertNotNil(DomainRegistry.identityService)
        XCTAssertNotNil(DomainRegistry.gatekeeperRepository)
        XCTAssertNotNil(DomainRegistry.gatekeeperRepository.gatekeeper())
    }

    func test_whenAppEnteresForeground_thenItInvalidatesAppIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 1
        appDelegate.applicationWillEnterForeground(UIApplication.shared)
        XCTAssertEqual(UIApplication.shared.applicationIconBadgeNumber, 0)
    }

    func test_defaultIdentifier() {
        // DO NOT CHANGE BECAUSE DEFAULT DATABASE LOCATION MIGHT CHANGE
        XCTAssertEqual(appDelegate.defaultBundleIdentifier, "io.gnosis.safe")
    }
}

class MockCoordinator: MainFlowCoordinator {

    var didBecomeActive = false

    override func appEntersForeground() {
        didBecomeActive = true
    }

    override func setUp() {
        super.setUp()
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
    }

}
