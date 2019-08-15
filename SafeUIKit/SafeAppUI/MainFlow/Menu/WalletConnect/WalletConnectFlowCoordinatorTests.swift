//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import SafeUIKit

class WalletConnectFlowCoordinatorTests: XCTestCase {

    let nav = UINavigationController()
    var fc: WalletConnectFlowCoordinator!
    let service = MockWalletConnectApplicationService(chainId: 1)

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletConnectApplicationService.self)
        fc = WalletConnectFlowCoordinator(rootViewController: nav)
    }

    func test_whenOnboardingDone_thenShowsSessionList() {
        service.markOnboardingDone()
        fc.setUp()
        XCTAssertTrue(fc.topViewController is WCSessionListTableViewController)
    }

    func test_whenOnboardingNeeded_thenShowsOnboarding() {
        fc.isAnimationEnabled = false
        fc.navigationController.loadViewIfNeeded()
        fc.push(UIViewController())

        service.markOnboardingNeeded()
        fc.setUp()
        XCTAssertTrue(fc.topViewController is OnboardingViewController)

        // cycle through steps
        let vc = fc.onboardingController!
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.steps.count, 3)

        vc.steps[0].action()
        XCTAssertEqual(vc.currentPageIndex, 1)

        vc.steps[1].action()
        XCTAssertEqual(vc.currentPageIndex, 2)

        vc.steps[2].action()
        XCTAssertEqual(fc.topViewController, fc.sessionListController)
    }

    func test_whenFinishesOnboarding_thenShowsSessionList() {
        fc.isAnimationEnabled = false
        fc.navigationController.loadViewIfNeeded()
        fc.push(UIViewController())
        service.markOnboardingNeeded()
        fc.setUp()

        fc.finishOnboarding()

        XCTAssertNil(fc.onboardingController?.parent, "Onboarding controller is still in navigation stack")
        XCTAssertTrue(service.isOnboardingDone())
    }

    func test_whenShowingScan_thenOpensScanner() {
        service.markOnboardingDone()
        let vc = TestSessionListController()
        fc.sessionListController = vc
        fc.showScan()
        XCTAssertTrue(vc.didScan)
    }

    func test_whenHasDeferredURL_thenOpensSessionsWithURL() {
        let url = URL(string: "wc:123")!
        fc = WalletConnectFlowCoordinator(connectionURL: url, rootViewController: nav)
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
