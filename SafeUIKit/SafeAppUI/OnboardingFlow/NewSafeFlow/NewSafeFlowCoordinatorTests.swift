//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class NewSafeFlowCoordinatorTests: SafeTestCase {

    var newSafeFlowCoordinator: NewSafeFlowCoordinator!
    let nav = UINavigationController()
    var startVC: UIViewController!
    let address = "test_address"

    var topViewController: UIViewController? {
        return newSafeFlowCoordinator.navigationController.topViewController
    }
    
    override func setUp() {
        super.setUp()
        newSafeFlowCoordinator = NewSafeFlowCoordinator(rootViewController: UINavigationController())
        newSafeFlowCoordinator.setUp()
    }

    func test_startViewController_returnsSetupSafeStartVC() {
        XCTAssertTrue(topViewController is NewSafeViewController)
    }

    func test_didSelectBrowserExtensionSetup_showsPairWithBrowserExtensionFlowCoordinatorStartVC() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: PairWithBrowserExtensionFlowCoordinator(address: nil))
        let expectedViewController = testFC.topViewController

        newSafeFlowCoordinator.didSelectBrowserExtensionSetup()
        delay()

        let finalTransitionedViewController = newSafeFlowCoordinator.navigationController.topViewController
        XCTAssertTrue(type(of: finalTransitionedViewController) == type(of: expectedViewController))
    }

    func test_pairWithBrowserExtensionCompletion_popsToStartVC() {
        let startVC = topViewController
        newSafeFlowCoordinator.didSelectBrowserExtensionSetup()
        delay()
        newSafeFlowCoordinator.pairWithExtensionFlowCoordinator.didPair(address)
        delay()
        XCTAssertTrue(topViewController === startVC)
    }

    func test_pairWithBrowserExtensionCompletion_callsConfirmBrowserExtension() {
        newSafeFlowCoordinator.didSelectBrowserExtensionSetup()
        newSafeFlowCoordinator.pairWithExtensionFlowCoordinator.didPair(address)
        XCTAssertEqual(identityService.confirmedBrowserExtensionAddress, address)
    }

    func test_whenSelectedPaperWalletSetup_thenTransitionsToPaperWalletCoordinator() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: PaperWalletFlowCoordinator(draftSafe: nil))
        let expectedViewController = testFC.topViewController

        newSafeFlowCoordinator.didSelectPaperWalletSetup()

        let finalTransitionedViewController = newSafeFlowCoordinator.navigationController.topViewController
        XCTAssertTrue(type(of: finalTransitionedViewController) == type(of: expectedViewController))
    }

    func test_didSelectNext_presentsNextController() {
        newSafeFlowCoordinator.didSelectNext()
        delay()
        XCTAssertTrue(topViewController is PendingSafeViewController)
    }

    func test_paperWalletSetupCompletion_popsToStartVC() {
        let startVC = topViewController
        newSafeFlowCoordinator.didSelectPaperWalletSetup()
        delay()
        newSafeFlowCoordinator.paperWalletFlowCoordinator.didConfirm()
        delay()
        XCTAssertTrue(topViewController === startVC)
    }

    func test_paperWalletSetupCompletion_callsConfirmPaperWallet() {
        newSafeFlowCoordinator.didSelectPaperWalletSetup()
        newSafeFlowCoordinator.paperWalletFlowCoordinator.didConfirm()
        XCTAssertTrue(identityService.didCallConfirmPaperWallet)
    }


}

class TestFlowCoordinator: FlowCoordinator {

    init() {
        super.init(rootViewController: UINavigationController())
    }

    var topViewController: UIViewController? {
        return navigationController.topViewController
    }
}
