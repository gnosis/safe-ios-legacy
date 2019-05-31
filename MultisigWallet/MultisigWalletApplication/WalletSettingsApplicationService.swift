//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

open class WalletSettingsApplicationService {

    public init() {}

    public func resyncWithBrowserExtension() throws {
        guard let wallet = DomainRegistry.walletRepository.selectedWallet() else { return }
        try DomainRegistry.communicationService.notifyWalletCreated(walletID: wallet.id)
    }

}
