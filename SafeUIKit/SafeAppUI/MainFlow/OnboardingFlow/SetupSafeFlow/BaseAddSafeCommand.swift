//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class BaseAddSafeCommand: MenuCommand {

    override var isHidden: Bool {
        ApplicationServiceRegistry.walletService.wallets().isEmpty
    }

    var selectedWalletID: String?
    var newWalletID: String?

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        selectedWalletID = ApplicationServiceRegistry.walletService.selectedWalletID()
        assert(selectedWalletID != nil)
        ApplicationServiceRegistry.walletService.cleanUpDrafts()

        createDraft()

        newWalletID = ApplicationServiceRegistry.walletService.selectedWalletID()
        assert(newWalletID != nil)
        assert(selectedWalletID != newWalletID)
        mainFlowCoordinator.saveCheckpoint()

        mainFlowCoordinator.enter(flow: childFlowCoordinator) { [weak mainFlowCoordinator, weak self] in
            guard let fc = mainFlowCoordinator, let `self` = self else { return }
            self.willExitToMenu(mainFlowCoordinator: fc)
        }
    }

    func willExitToMenu(mainFlowCoordinator: MainFlowCoordinator) {
        // exiting back to menu means that the CreateSafe flow either finished successfully (selected wallet is
        // ready to use), or there was a failure or cancellation.

        // Note, that if the menu will be opened from within the CreateSafe Flow Coordinator,
        // it will open a completely new Menu VC, and hence this command will not interfere with that new menu.

        assert(ApplicationServiceRegistry.walletService.selectedWalletID() != nil)
        assert(selectedWalletID != nil)

        if newWalletID == ApplicationServiceRegistry.walletService.selectedWalletID() {
            assert(ApplicationServiceRegistry.walletService.hasReadyToUseWallet)
            DispatchQueue.main.async(execute: mainFlowCoordinator.switchToRootController)
        } else {
            // creation failed, keep previous selection.
            ApplicationServiceRegistry.walletService.selectWallet(selectedWalletID!)
            DispatchQueue.main.async(execute: mainFlowCoordinator.popToLastCheckpoint)
        }
    }

    func createDraft() {
        // to override
    }

}
