//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class ConnectTwoFACommand: MenuCommand {

    override var title: String {
        return LocalizedString("connect_2fa", comment: "Connect 2FA")
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.connectExtensionService.isAvailable
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        let fc = ConnectTwoFAFlowCoordinator()
        fc.mainFlowCoordinator = mainFlowCoordinator
        childFlowCoordinator = fc
        super.run(mainFlowCoordinator: mainFlowCoordinator)
    }

}
