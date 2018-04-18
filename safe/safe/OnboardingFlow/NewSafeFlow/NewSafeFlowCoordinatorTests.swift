//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import CommonTestSupport

class NewSafeFlowCoordinatorTests: SafeTestCase {

    let newSafeFlowCoordinator = NewSafeFlowCoordinator()
    let nav = UINavigationController()
    var startVC: UIViewController!

    override func setUp() {
        super.setUp()
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

    func test_didSelectChromeExtensionSetup_showsPairWithChromeExtensionVC() {
        newSafeFlowCoordinator.didSelectChromeExtensionSetup()
        delay()
        XCTAssertTrue(type(of: nav.topViewController!) == type(of: PairWithChromeExtensionViewController()))
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

}
