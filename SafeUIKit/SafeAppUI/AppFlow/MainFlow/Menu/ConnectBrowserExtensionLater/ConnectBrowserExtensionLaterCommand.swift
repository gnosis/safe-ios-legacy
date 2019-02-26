//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class ConnectBrowserExtensionLaterCommand: MenuCommand {

    override var title: String {
        return LocalizedString("menu.action.connect_browser_extension",
                               comment: "Connect browser extension menu item.")
    }

    override var isHidden: Bool {
        return ApplicationServiceRegistry.settingsService.replaceBrowserExtensionIsAvailable
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {}

}
