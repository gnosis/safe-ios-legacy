//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class RecoverSafeCommand: BaseAddSafeCommand {

    override var title: String {
        LocalizedString("recover_existing_safe_menu", comment: "Recover Safe")
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        childFlowCoordinator = mainFlowCoordinator.recoverSafeFlowCoordinator
        super.run(mainFlowCoordinator: mainFlowCoordinator)
    }

    override func createDraft() {
        ApplicationServiceRegistry.recoveryService.createRecoverDraftWallet()
    }

}
