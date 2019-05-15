//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ReplaceRecoveryPhraseCommand: MenuCommand {

    override var title: String {
        return LocalizedString("ios_replace_recovery_phrase", comment: "Change recovery key menu item")
            .replacingOccurrences(of: "\n", with: " ").capitalized
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        mainFlowCoordinator.saveCheckpoint()
        mainFlowCoordinator.replaceRecoveryController = mainFlowCoordinator.mnemonicIntroViewController()
        mainFlowCoordinator.push(mainFlowCoordinator.replaceRecoveryController)
    }

}
