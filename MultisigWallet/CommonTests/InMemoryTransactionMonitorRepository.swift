//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class InMemoryTransactionMonitorRepository: RBETransactionMonitorRepository {

    var items = [RBETransactionMonitorEntry]()

    public init() {}

    public func save(_ entry: RBETransactionMonitorEntry) {
        items.append(entry)
    }

    public func remove(_ entry: RBETransactionMonitorEntry) {
        items.removeAll { $0 == entry }
    }

    public func find(id: TransactionID) -> RBETransactionMonitorEntry? {
        return items.first { $0.transactionID == id }
    }

    public func findAll() -> [RBETransactionMonitorEntry] {
        return items
    }

}
