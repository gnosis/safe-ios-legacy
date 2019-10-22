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
        ApplicationServiceRegistry.walletService.cleanUpDrafts()
        createDraft()
        MainFlowCoordinator.shared.enter(flow: childFlowCoordinator)
    }

    func createDraft() {
        // to override
    }

}
