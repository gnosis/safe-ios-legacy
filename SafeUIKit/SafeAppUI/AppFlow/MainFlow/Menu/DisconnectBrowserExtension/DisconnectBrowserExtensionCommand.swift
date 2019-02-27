//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class DisconnectBrowserExtensionCommand: MenuCommand {

    override var title: String {
        return LocalizedString("menu.action.disconnect_browser_extension",
                               comment: "Disconnect browser extension menu item")
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.disconnectExtensionService.isAvailable
    }

    override init() {
        super.init()
        childFlowCoordinator = DisconnectBrowserExtensionFlowCoordinator()
    }

}
