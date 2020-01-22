//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class LoadMultisigCommand: MenuCommand {

    override var title: String {
        return "Load Multisig"
    }

    override var isHidden: Bool {
        return ApplicationServiceRegistry.walletService.wallets().isEmpty
    }

    override init() {
        super.init()
        childFlowCoordinator = LoadMultisigFlowCoordinator()
    }

}
