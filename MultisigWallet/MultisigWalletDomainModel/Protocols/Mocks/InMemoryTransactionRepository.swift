//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class InMemoryTransactionRepository: BaseInMemoryRepository<Transaction, TransactionID>, TransactionRepository {

    public func nextID() -> TransactionID {
        return TransactionID()
    }

}
