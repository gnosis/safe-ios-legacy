//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class EditSafeNameCommand: MenuCommand {

    override var title: String {
        return LocalizedString("edit_safe_name", comment: "Edit Safe name")
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.walletService.hasSelectedWallet
    }

    override func run() {
        MainFlowCoordinator.shared.push(EditSafeNameViewController())
    }

}
