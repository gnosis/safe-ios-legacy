//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class DisconnectTwoFACommand: MenuCommand {

    override var title: String {
        return LocalizedString("ios_disconnect_browser_extension", comment: "Disconnect browser extension")
            .replacingOccurrences(of: "\n", with: " ").capitalized
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.disconnectTwoFAService.isAvailable
    }

    override init() {
        super.init()
        childFlowCoordinator = DisconnectTwoFAFlowCoordinator()
    }

}
