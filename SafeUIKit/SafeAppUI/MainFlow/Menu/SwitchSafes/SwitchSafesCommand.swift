//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class SwitchSafesCommand: MenuCommand {

    override var title: String {
        return LocalizedString("switch_safe", comment: "Switch Safe")
    }

    override var isHidden: Bool {
        return ApplicationServiceRegistry.walletService.hasSelectedWallet
    }

    override init() {
        super.init()
        childFlowCoordinator = SwitchSafesFlowCoordinator()
    }

}
