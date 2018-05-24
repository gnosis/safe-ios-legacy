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
    var completionCalled = false

    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(try walletService.createNewDraftWallet())
        ethereumService.prepareToGenerateExternallyOwnedAccount(address: "address", mnemonic: ["a", "b"])
        coordinator = PaperWalletFlowCoordinator(rootViewController: UINavigationController())
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

    func test_startViewController_whenWordsAreEmpty_thenTheyAreNotDisplayed() {
        ethereumService.prepareToGenerateExternallyOwnedAccount(address: "address", mnemonic: [])
        let startVC = topViewController as! SaveMnemonicViewController
        startVC.loadViewIfNeeded()
        let text = startVC.mnemonicCopyableLabel.text ?? ""
        XCTAssertTrue(text.isEmpty)
    }

    func test_didPressContinue_whePaperWalletAlreadyExists_thenCallsCompletion() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: coordinator) {
            self.completionCalled = true
        }
        walletService.addOwner(address: "address", type: .paperWallet)
        coordinator.didPressContinue()
        XCTAssertTrue(completionCalled)
    }

    func test_didConfirm_callsCompletion() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: coordinator) {
            self.completionCalled = true
        }
        coordinator.didConfirm()
        XCTAssertTrue(completionCalled)
    }

    func test_whenSetUp_thenPushesMnemonicController() throws {
        XCTAssertTrue(topViewController is SaveMnemonicViewController)
    }

    func test_whenContinuesDuringUnconfirmedSafe_thenPushesConfirmController() {
        createWindow(coordinator.rootViewController)
        let saveMnemonicController = topViewController as! SaveMnemonicViewController
        delay()
        coordinator.didPressContinue()
        delay()
        XCTAssertTrue(topViewController is ConfirmMnemonicViewController)
        let confirmMnemonicController = topViewController as! ConfirmMnemonicViewController
        XCTAssertTrue(confirmMnemonicController.delegate === coordinator)
        XCTAssertEqual(confirmMnemonicController.words, saveMnemonicController.account.mnemonicWords)
    }

}
