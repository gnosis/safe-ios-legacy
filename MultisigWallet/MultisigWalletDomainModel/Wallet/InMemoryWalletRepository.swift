//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

/// In-memory implementation of WalletRepository, used for testing.
open class InMemoryWalletRepository: BaseInMemoryRepository<Wallet, WalletID>, WalletRepository {

    open func nextID() -> WalletID {
        return WalletID()
    }

}
