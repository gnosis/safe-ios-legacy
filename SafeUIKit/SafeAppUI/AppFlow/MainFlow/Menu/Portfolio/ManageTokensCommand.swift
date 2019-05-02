//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ManageTokensCommand: MenuCommand {

    override var title: String {
        return LocalizedString("manage_tokens", comment: "Manage Tokens menu item").capitalized
    }

    override init() {
        super.init()
        childFlowCoordinator = ManageTokensFlowCoordinator()
    }

    override func didExitToMenu(mainFlowCoordinator: MainFlowCoordinator) {
        // no-op
    }

}
