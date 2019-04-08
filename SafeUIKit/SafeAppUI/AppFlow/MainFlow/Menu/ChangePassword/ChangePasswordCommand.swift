//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ChangePasswordCommand: MenuCommand {

    override var title: String {
        return LocalizedString("menu.action.change_password", comment: "Change password menu item")
    }

    override init() {
        super.init()
        childFlowCoordinator = ChangePasswordFlowCoordinator()
    }

    override func didExitToMenu(mainFlowCoordinator: MainFlowCoordinator) {
        // no-op
    }

}
