//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ChangePasswordCommand: MenuCommand {

    override var title: String {
        return LocalizedString("change_password", comment: "Change password").capitalized
    }

    override init() {
        super.init()
        childFlowCoordinator = ChangePasswordFlowCoordinator()
    }

    override func didExitToMenu() {
        // no-op
    }

}
