//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class BaseAddSafeCommand: MenuCommand {

    override var isHidden: Bool {
        ApplicationServiceRegistry.walletService.wallets().isEmpty
    }

    override func run() {
        let selectedSafe = ApplicationServiceRegistry.walletService.selectedWalletID()!
        ApplicationServiceRegistry.walletService.cleanUpDrafts()
        createDraft()
        let selectedDraft = ApplicationServiceRegistry.walletService.selectedWalletID()!
        assert(selectedSafe != selectedDraft)
        MainFlowCoordinator.shared.enter(flow: childFlowCoordinator) {
            // when we abort the flow and go back, the draft will be removed, there we re-select previous safe.
            if !ApplicationServiceRegistry.walletService.wallets().contains(where: { $0.id == selectedDraft }) {
                ApplicationServiceRegistry.walletService.selectWallet(selectedSafe)
            }
        }
    }

    func createDraft() {
        // to override
    }

}
