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

    override func setUp() {
        super.setUp()
        newSafeFlowCoordinator = NewSafeFlowCoordinator()
        startVC = newSafeFlowCoordinator.startViewController(parent: nav)
        nav.pushViewController(startVC, animated: false)
    }

    func test_startViewController_returnsSetupSafeStartVC() {
        XCTAssertTrue(nav.topViewController is NewSafeViewController)
    }

    func test_didSelectPaperWalletSetup_showsPaperWalletFlowCoordinatorStartVC() {
        newSafeFlowCoordinator.didSelectPaperWalletSetup()
        delay()
        let fc = PaperWalletFlowCoordinator(draftSafe: nil)
        let paperWalletStartVC = fc.startViewController(parent: newSafeFlowCoordinator.rootVC)
        XCTAssertTrue(type(of: nav.topViewController!) == type(of: paperWalletStartVC))
    }

    func test_didSelectBrowserExtensionSetup_showsPairWithBrowserExtensionFlowCoordinatorStartVC() {
        newSafeFlowCoordinator.didSelectBrowserExtensionSetup()
        delay()
        let fc = PairWithBrowserExtensionFlowCoordinator(address: nil) { _ in }
        let pairVC = fc.startViewController(parent: newSafeFlowCoordinator.rootVC)
        XCTAssertTrue(type(of: nav.topViewController!) == type(of: pairVC))
    }

    func test_didSelectNext_presentsReviewSafeViewController() {
        newSafeFlowCoordinator.didSelectNext()
        delay()
        XCTAssertTrue(nav.topViewController! is PendingSafeViewController)
    }

    func test_paperWalletSetupCompletion_popsToStartVC() {
        newSafeFlowCoordinator.didSelectPaperWalletSetup()
        delay()
        newSafeFlowCoordinator.paperWalletFlowCoordinator.didConfirm()
        delay()
        XCTAssertTrue(nav.topViewController === startVC)
    }

    func test_paperWalletSetupCompletion_callsConfirmPaperWallet() {
        newSafeFlowCoordinator.didSelectPaperWalletSetup()
        newSafeFlowCoordinator.paperWalletFlowCoordinator.didConfirm()
        XCTAssertTrue(identityService.didCallConfirmPaperWallet)
    }

    func test_pairWithBrowserExtensionCompletion_popsToStartVC() {
        newSafeFlowCoordinator.didSelectBrowserExtensionSetup()
        delay()
        newSafeFlowCoordinator.pairWithBrowserExtensionFlowCoordinator.didPair(address)
        delay()
        XCTAssertTrue(nav.topViewController === startVC)
    }

    func test_pairWithBrowserExtensionCompletion_callsConfirmBrowserExtension() {
        newSafeFlowCoordinator.didSelectBrowserExtensionSetup()
        newSafeFlowCoordinator.pairWithBrowserExtensionFlowCoordinator.didPair(address)
        XCTAssertEqual(identityService.confirmedBrowserExtensionAddress, address)
    }

}
