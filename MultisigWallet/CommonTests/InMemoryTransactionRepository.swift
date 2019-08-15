//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

/// In-memory implementation of TransactionRepository, used for testing.
open class InMemoryTransactionRepository: BaseInMemoryRepository<Transaction, TransactionID>, TransactionRepository {

    public func find(type: TransactionType, wallet: WalletID) -> Transaction? {
        return nil
    }

    public func find(hash: Data, status: TransactionStatus.Code) -> Transaction? {
        return all().first { $0.hash == hash && $0.status == status }
    }

    public func find(hash: Data) -> Transaction? {
        return all().first { $0.hash == hash }
    }

    public func nextID() -> TransactionID {
        return TransactionID()
    }

}
