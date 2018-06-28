//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class InMemoryWalletRepository: BaseInMemoryRepository<Wallet, WalletID>, WalletRepository {

    open func nextID() -> WalletID {
        return try! WalletID()
    }

}
