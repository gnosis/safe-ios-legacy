//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public final class InMemoryWCProcessingTransactionsRepository: WCProcessingTransactionsRepository {

    private var processingTransactions = [WCTransaction]()

    public init() {}

    public func add(transaction: WCTransaction) {
        processingTransactions.append(transaction)
    }

    public func find(transactionID: TransactionID) -> WCTransaction? {
        return processingTransactions.first(where: { $0.transactionID == transactionID })
    }

    public func remove(transactionID: TransactionID) {
        processingTransactions.removeAll { $0.transactionID == transactionID }
    }

}
