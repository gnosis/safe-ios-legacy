//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

/// In-memory implementation of TransactionRepository, used for testing.
open class InMemoryTransactionRepository: BaseInMemoryRepository<Transaction, TransactionID>, TransactionRepository {

    public func findBy(hash: Data, status: TransactionStatus.Code) -> Transaction? {
        return items.first { $0.hash == hash && $0.status == status }
    }

    public func findBy(hash: Data) -> Transaction? {
        return items.first { $0.hash == hash }
    }

    public func nextID() -> TransactionID {
        return TransactionID()
    }

}
