//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class BaseAddSafeCommand: MenuCommand {

    override var isHidden: Bool {
        ApplicationServiceRegistry.walletService.wallets().isEmpty
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        ApplicationServiceRegistry.walletService.cleanUpDrafts()
        createDraft()
        mainFlowCoordinator.enter(flow: childFlowCoordinator)
    }

    func createDraft() {
        // to override
    }

}
