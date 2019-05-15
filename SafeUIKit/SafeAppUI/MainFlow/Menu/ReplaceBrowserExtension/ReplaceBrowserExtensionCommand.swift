//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class ReplaceBrowserExtensionCommand: MenuCommand {

    override var title: String {
        return LocalizedString("replace_browser_extension", comment: "Replace browser extension")
            .replacingOccurrences(of: "\n", with: " ").capitalized
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.replaceExtensionService.isAvailable
    }

    override init() {
        super.init()
        childFlowCoordinator = ReplaceBrowserExtensionFlowCoordinator()
    }

}
