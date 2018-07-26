//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class InMemoryTransactionRepository: BaseInMemoryRepository<Transaction, TransactionID>, TransactionRepository {

    public func findByHash(_ hash: Data) -> Transaction? {
        return items.first { $0.hash == hash }
    }

    public func nextID() -> TransactionID {
        return TransactionID()
    }

}
