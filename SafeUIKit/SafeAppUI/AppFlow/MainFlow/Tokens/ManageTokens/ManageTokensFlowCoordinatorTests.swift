//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import CommonTestSupport

class ManageTokensFlowCoordinatorTests: XCTestCase {

    var flowCoordinator: ManageTokensFlowCoordinator!
    let walletService = MockWalletApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        flowCoordinator = ManageTokensFlowCoordinator(rootViewController: UINavigationController())
        flowCoordinator.setUp()
    }

    func test_whenSetupCalled_thenShowsManageTokensScreen() {
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is ManageTokensTableViewController)
    }

    func test_whenAddsToken_thenShowsAddTokenVC() {
        createWindow(flowCoordinator.rootViewController)
        flowCoordinator.addToken()
        delay()
        XCTAssertTrue(flowCoordinator.rootViewController.presentedViewController is UINavigationController)
        let topVC = flowCoordinator.rootViewController.presentedViewController?.childViewControllers[0]
        XCTAssertTrue(topVC is AddTokenTableViewController)
    }

    func test_whenSelectingToken_thenAddTokenVCIsDismissed() {
        createWindow(flowCoordinator.rootViewController)
        flowCoordinator.addToken()
        delay()
        XCTAssertTrue(flowCoordinator.rootViewController.presentedViewController is UINavigationController)
        flowCoordinator.didSelectToken(TokenData.gno)
        delay(1)
        XCTAssertNil(flowCoordinator.rootViewController.presentedViewController)
    }

    func test_whenRearranginTokens_thenApplicationServiceIsCalled() {
        flowCoordinator.rearrange(tokens: [])
        XCTAssertTrue(walletService.didRearrange)
    }

    func test_whenHidingToken_thenApplicationServiceIsCalled() {
        flowCoordinator.hide(token: TokenData.gno)
        XCTAssertEqual(walletService.blacklistInput, TokenData.gno)
    }

}
