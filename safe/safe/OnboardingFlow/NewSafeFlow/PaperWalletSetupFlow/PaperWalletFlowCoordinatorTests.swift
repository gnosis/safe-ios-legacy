//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import CommonTestSupport
import IdentityAccessDomainModel
import IdentityAccessApplication
import IdentityAccessImplementations


class PaperWalletFlowCoordinatorTests: SafeTestCase {

    var flowCoordinator: PaperWalletFlowCoordinator!
    var nav = UINavigationController()
    var draftSafe: DraftSafe!
    var completionCalled = false

    override func setUp() {
        super.setUp()
        draftSafe = try! identityService.createDraftSafe()
        flowCoordinator = PaperWalletFlowCoordinator(draftSafe: draftSafe) { [unowned self] in
            self.completionCalled = true
        }
        let startVC = flowCoordinator.startViewController(parent: nav)
        nav.pushViewController(startVC, animated: false)
    }

    func test_startViewController_createsSaveMnemonicViewControllerWithDelegate() {
        XCTAssertTrue(nav.topViewController is SaveMnemonicViewController)
        let controller = nav.topViewController as! SaveMnemonicViewController
        XCTAssertTrue(controller.delegate === flowCoordinator)
    }

    func test_startViewController_whenDraftSafeIsNil_thenWordsAreEmpty() {
        flowCoordinator = PaperWalletFlowCoordinator(draftSafe: nil)
        let startVC = flowCoordinator.startViewController(parent: nav) as! SaveMnemonicViewController
        XCTAssertTrue(startVC.words.isEmpty)
    }

    func test_didPressContinue_whenDraftSafePaperWalletIsNotConfirmed_thenPushesConfirmMnemonicViewController() {
        flowCoordinator.didPressContinue()
        delay()
        XCTAssertTrue(nav.topViewController is ConfirmMnemonicViewController)
        let controller = nav.topViewController as! ConfirmMnemonicViewController
        XCTAssertTrue(controller.delegate === flowCoordinator)
        XCTAssertEqual(controller.words, draftSafe.paperWalletMnemonicWords)
    }

    func test_didPressContinue_whenDraftSafePaperWalletIsConfirmed_thenCallsCompletion() {
        identityService.confirmPaperWallet(draftSafe: draftSafe)
        flowCoordinator.didPressContinue()
        XCTAssertTrue(completionCalled)
    }

    func test_didConfirm_callsCompletion() {
        flowCoordinator.didConfirm()
        XCTAssertTrue(completionCalled)
    }

}
