//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class ReplaceBrowserExtensionCommand: MenuCommand {

    override var title: String {
        return LocalizedString("menu.action.change_browser_extension",
                               comment: "Change browser extension menu item")
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.replaceExtensionService.isAvailable
    }

    var commandFlow = ReplaceBrowserExtensionFlowCoordinator()

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        mainFlowCoordinator.saveCheckpoint()
        mainFlowCoordinator.enter(flow: commandFlow) { [unowned mainFlowCoordinator] in
            DispatchQueue.main.async {
                mainFlowCoordinator.popToLastCheckpoint()
                mainFlowCoordinator.pop()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                    mainFlowCoordinator.showTransactionList()
                }
            }
        }
    }

}
