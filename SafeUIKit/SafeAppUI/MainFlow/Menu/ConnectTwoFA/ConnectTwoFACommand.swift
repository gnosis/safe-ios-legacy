//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class ConnectTwoFACommand: MenuCommand {

    override var title: String {
        return LocalizedString("enable_2fa_full", comment: "Connect 2FA")
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.connectTwoFAService.isAvailable
    }

    override init() {
        super.init()
        childFlowCoordinator = ConnectTwoFAFlowCoordinator()
    }

}
