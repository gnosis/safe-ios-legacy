//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class CreateSafeCommand: BaseAddSafeCommand {

    override var title: String {
        LocalizedString("create_new_safe", comment: "Create Safe")
    }

    override init() {
        super.init()
        childFlowCoordinator = CreateSafeFlowCoordinator()
    }

    override func createDraft() {
        ApplicationServiceRegistry.walletService.createNewDraftWallet()
    }

}
