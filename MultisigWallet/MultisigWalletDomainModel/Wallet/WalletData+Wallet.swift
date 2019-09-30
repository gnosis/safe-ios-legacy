//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public extension WalletData {

    init?(wallet: Wallet) {
        var walletState: WalletData.State!
        if wallet.state.isReadyToUse {
            walletState = .created
        } else if !wallet.state.canChangeAddress {
            // wallet can change address only before all owners are known and deployments process is started
            walletState = .pending
        } else {
            return nil
        }
        self.init(id: wallet.id.id, address: wallet.address.value, name: "Wallet", state: walletState)
    }

}
