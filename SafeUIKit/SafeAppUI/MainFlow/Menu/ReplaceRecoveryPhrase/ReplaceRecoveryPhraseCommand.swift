//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ReplaceRecoveryPhraseCommand: MenuCommand {

    override var title: String {
        return LocalizedString("replace_recovery_phrase", comment: "Change recovery key menu item")
            .replacingOccurrences(of: "\n", with: " ").capitalized
    }

    override init() {
        super.init()
        childFlowCoordinator = ReplaceRecoveryPhraseFlowCoordinator()
    }

}
