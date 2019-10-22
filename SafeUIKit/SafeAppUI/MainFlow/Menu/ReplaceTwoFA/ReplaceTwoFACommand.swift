//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class ReplaceTwoFACommand: MenuCommand {

    override var title: String {
        return LocalizedString("replace_2fa_full", comment: "Replace 2FA")
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.replaceTwoFAService.isAvailable
    }

    override init() {
        super.init()
        childFlowCoordinator = ReplaceTwoFAFlowCoordinator()
    }

}
