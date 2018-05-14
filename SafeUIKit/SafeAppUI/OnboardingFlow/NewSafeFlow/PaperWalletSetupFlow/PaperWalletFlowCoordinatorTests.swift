//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import IdentityAccessDomainModel
import IdentityAccessApplication
import IdentityAccessImplementations


class PaperWalletFlowCoordinatorTests: SafeTestCase {

    var coordinator: PaperWalletFlowCoordinator!
    var draftSafe: DraftSafe!
    var completionCalled = false

    override func setUp() {
        super.setUp()
        draftSafe = try! identityService.createDraftSafe()
        coordinator = PaperWalletFlowCoordinator(draftSafe: draftSafe)
        coordinator.rootVC = UINavigationController()
        coordinator.setUp()
    }

    var topViewController: UIViewController? {
        return coordinator.navigationController.topViewController
    }

    func test_startViewController_createsSaveMnemonicViewControllerWithDelegate() {
        XCTAssertTrue(topViewController is SaveMnemonicViewController)
        let controller = topViewController as! SaveMnemonicViewController
        XCTAssertTrue(controller.delegate === coordinator)
    }

    func test_startViewController_whenDraftSafeIsNil_thenWordsAreEmpty() {
        coordinator = PaperWalletFlowCoordinator(draftSafe: nil)
        coordinator.rootVC = UINavigationController()
        coordinator.setUp()
        let startVC = topViewController as! SaveMnemonicViewController
        XCTAssertTrue(startVC.words.isEmpty)
    }

    func test_didPressContinue_whenDraftSafePaperWalletIsConfirmed_thenCallsCompletion() {
        let testFC = TestFlowCoordinator()
        testFC.transition(to: coordinator) {
            self.completionCalled = true
        }
        identityService.confirmPaperWallet(draftSafe: draftSafe)
        coordinator.didPressContinue()
        XCTAssertTrue(completionCalled)
    }

    func test_didConfirm_callsCompletion() {
        let testFC = TestFlowCoordinator()
        testFC.transition(to: coordinator) {
            self.completionCalled = true
        }
        coordinator.didConfirm()
        XCTAssertTrue(completionCalled)
    }

    func test_whenSetUp_thenPushesMnemonicController() throws {
        XCTAssertTrue(topViewController is SaveMnemonicViewController)
    }

    func test_whenContinuesDuringUnconfirmedSafe_thenPushesConfirmController() {
        coordinator.didPressContinue()
        delay()
        XCTAssertTrue(topViewController is ConfirmMnemonicViewController)
        let controller = topViewController as! ConfirmMnemonicViewController
        XCTAssertTrue(controller.delegate === coordinator)
        XCTAssertEqual(controller.words, draftSafe.paperWalletMnemonicWords)
    }

}
