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
        walletService.createNewDraftWallet()
        ethereumService.prepareToGenerateExternallyOwnedAccount(address: "address", mnemonic: ["a", "b"])
        coordinator = PaperWalletFlowCoordinator(rootViewController: UINavigationController())
        coordinator.setUp()
    }

    var topViewController: UIViewController? {
        return coordinator.navigationController.topViewController
    }

    func test_didPressContinue_whePaperWalletAlreadyExists_thenCallsCompletion() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: coordinator) {
            self.completionCalled = true
        }
        walletService.addOwner(address: "address", type: .paperWallet)
        let startVC = topViewController as! ShowSeedViewController
        coordinator.showSeedViewControllerDidPressContinue(startVC)
        XCTAssertTrue(completionCalled)
    }

    func test_didConfirm_callsCompletion() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: coordinator) {
            self.completionCalled = true
        }
        coordinator.enterSeedViewControllerDidSubmit(EnterSeedViewController())
        XCTAssertTrue(completionCalled)
    }

    func test_whenSetUp_thenPushesMnemonicController() throws {
        XCTAssertTrue(topViewController is ShowSeedViewController)
    }

    // TOOD: enable, it crashes - ios 13
    func _test_whenContinuesDuringUnconfirmedSafe_thenPushesConfirmController() {
        createWindow(coordinator.rootViewController)
        delay()
        let startVC = topViewController as! ShowSeedViewController
        coordinator.showSeedViewControllerDidPressContinue(startVC)
        delay()
        XCTAssertTrue(topViewController is EnterSeedViewController)
        let enterSeedController = topViewController as! EnterSeedViewController
        XCTAssertTrue(enterSeedController.delegate === coordinator)
    }

}
