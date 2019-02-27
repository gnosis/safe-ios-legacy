//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class ReplaceBrowserExtensionCommand: MenuCommand {

    override var title: String {
        return LocalizedString("menu.action.change_browser_extension",
                               comment: "Change browser extension menu item")
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.replaceExtensionService.isAvailable
    }

    override init() {
        super.init()
        childFlowCoordinator = ReplaceBrowserExtensionFlowCoordinator()
    }

}
