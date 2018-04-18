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

    let flowCoordinator = PaperWalletFlowCoordinator()
    var nav = UINavigationController()

    override func setUp() {
        super.setUp()
        flowCoordinator.draftSafe = try! identityService.getOrCreateDraftSafe()
        let startVC = flowCoordinator.startViewController(parent: nav)
        nav.pushViewController(startVC, animated: false)
    }

    func test_startViewController_createsSaveMnemonicViewControllerWithDelegate() {
        XCTAssertTrue(nav.topViewController is SaveMnemonicViewController)
        let controller = nav.topViewController as! SaveMnemonicViewController
        XCTAssertTrue(controller.delegate === flowCoordinator)
    }

    func test_startViewController_whenDraftSafeIsNil_thenWordsAreEmpty() {
        flowCoordinator.draftSafe = nil
        let startVC = flowCoordinator.startViewController(parent: nav) as! SaveMnemonicViewController
        XCTAssertTrue(startVC.words.isEmpty)
    }

    func test_didPressContinue_pushesConfirmMnemonicViewControllerWithAllData() {
        flowCoordinator.didPressContinue()
        delay()
        XCTAssertTrue(nav.topViewController is ConfirmMnemonicViewController)
        let controller = nav.topViewController as! ConfirmMnemonicViewController
        XCTAssertTrue(controller.delegate === flowCoordinator)
        XCTAssertEqual(controller.words, flowCoordinator.draftSafe?.paperWalletMnemonicWords)
    }

    func test_didConfirm_callsCompletion() {
        var completionCalled = false
        flowCoordinator.completion = { completionCalled = true }
        flowCoordinator.didConfirm()
        XCTAssertTrue(completionCalled)
    }

}
