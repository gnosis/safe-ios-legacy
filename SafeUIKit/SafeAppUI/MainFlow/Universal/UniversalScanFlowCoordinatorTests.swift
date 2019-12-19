//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import SafeUIKit

class UniversalScanFlowCoordinatorTests: XCTestCase {

    let nav = UINavigationController()
    var fc: UniversalScanFlowCoordinator!
    let service = MockWalletConnectApplicationService(chainId: 1)

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletConnectApplicationService.self)
        fc = WalletConnectFlowCoordinator(rootViewController: nav)
    }

    func test_whenOnboardingDone_thenShowsScanner() {
        service.markOnboardingDone()
        fc.setUp()
        XCTAssertTrue(fc.visibleViewController is ScannerViewController)
    }

    func test_whenOnboardingNeeded_thenShowsOnboarding() {
        fc.isAnimationEnabled = false
        fc.navigationController.loadViewIfNeeded()
        fc.push(UIViewController())

        service.markOnboardingNeeded()
        fc.setUp()
        XCTAssertTrue(fc.visibleViewController is OnboardingViewController)

        // cycle through steps
        let vc = fc.onboardingController!
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.steps.count, 3)

        vc.steps[0].action()
        XCTAssertEqual(vc.currentPageIndex, 1)

        vc.steps[1].action()
        XCTAssertEqual(vc.currentPageIndex, 2)

        vc.steps[2].action()
        XCTAssertTrue(fc.visibleViewController is ScannerViewController)
    }

    func test_whenScannerNeeded_thenOpensScanner() {
        fc.showScan()
        XCTAssertTrue(fc.visibleViewController is ScannerViewController)
    }

    func test_whenFinishesOnboarding_thenShowsScanner() {
        fc.isAnimationEnabled = false
        fc.navigationController.loadViewIfNeeded()
        fc.push(UIViewController())
        service.markOnboardingNeeded()
        fc.setUp()

        fc.finishOnboarding()

        XCTAssertNil(fc.onboardingController?.parent, "Onboarding controller is still in navigation stack")
        XCTAssertTrue(service.isOnboardingDone())
        XCTAssertTrue(fc.visibleViewController is ScannerViewController)
    }

    func test_whenScanSuccess_thenOpensSessionsWithURL() {
        let url = URL(string: "wc:123")!
        fc = WalletConnectFlowCoordinator(rootViewController: nav)
        fc.connectionURL = url
        fc.showSessionList()
        XCTAssertEqual(fc.sessionListController!.connectionURL, url)
    }

}

class TestSessionListController: WCSessionListTableViewController {

    var didScan = false

    override func scan() {
        didScan = true
    }

}
