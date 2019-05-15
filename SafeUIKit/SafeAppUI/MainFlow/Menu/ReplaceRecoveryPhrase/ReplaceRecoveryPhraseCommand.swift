//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class ReplaceRecoveryPhraseCommand: MenuCommand {

    override var title: String {
        return LocalizedString("ios_replace_recovery_phrase", comment: "Change recovery key menu item")
            .replacingOccurrences(of: "\n", with: " ").capitalized
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.settingsService.isReplaceRecoveryAvailable()
    }

    override init() {
        super.init()
        childFlowCoordinator = ReplaceRecoveryPhraseFlowCoordinator()
    }

}
