//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class DisconnectTwoFACommand: MenuCommand {

    override var title: String {
        return LocalizedString("disconnect_2fa", comment: "Disconnect 2FA")
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.disconnectTwoFAService.isAvailable
    }

    override init() {
        super.init()
        childFlowCoordinator = DisconnectTwoFAFlowCoordinator()
    }

}
