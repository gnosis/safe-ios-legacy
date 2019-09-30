//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class SwitchSafesCommand: MenuCommand {

    override var title: String {
        return LocalizedString("switch_safes", comment: "Switch Safes")
    }

    override var isHidden: Bool {
        return ApplicationServiceRegistry.walletService.wallets().isEmpty
    }

    override init() {
        super.init()
        childFlowCoordinator = SwitchSafesFlowCoordinator()
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        (childFlowCoordinator as! SwitchSafesFlowCoordinator).mainFlowCoordinator = mainFlowCoordinator
        super.run(mainFlowCoordinator: mainFlowCoordinator)
    }

}
