//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class WalletConnectMenuCommand: MenuCommand {

    override var title: String {
        return LocalizedString("walletconnect", comment: "WalletConnect")
    }

    override var isHidden: Bool {
        return ApplicationServiceRegistry.walletConnectService.isAvaliable
    }

    override init() {
        super.init()
        childFlowCoordinator = WalletConnectFlowCoordinator()
    }

}
