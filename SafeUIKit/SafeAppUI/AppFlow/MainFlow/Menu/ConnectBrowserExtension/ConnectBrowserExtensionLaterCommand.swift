//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class ConnectBrowserExtensionLaterCommand: MenuCommand {

    private var commandFlow = ConnectBrowserExtensionFlowCoordinator()

    override var title: String {
        return LocalizedString("menu.action.connect_browser_extension",
                               comment: "Connect browser extension menu item.")
    }

    override var isHidden: Bool {
        return ApplicationServiceRegistry.connectExtensionService.isAvailable
    }

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
