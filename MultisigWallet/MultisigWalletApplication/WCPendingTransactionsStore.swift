//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public struct WCPendingTransaction {

    public var transactionID: TransactionID
    public var sessionData: WCSessionData
    public var completion: (Result<String, Error>) -> Void

    init(transactionID: TransactionID, sessionData: WCSessionData, completion: @escaping (Result<String, Error>) -> Void) {
        self.transactionID = transactionID
        self.sessionData = sessionData
        self.completion = completion
    }

}

// TODO: test
final class WCPendingTransactionsStore {

    private var pendingTransactions = [WCPendingTransaction]()

    func addPendingTransaction(_ transaction: WCPendingTransaction) {
        pendingTransactions.append(transaction)
    }

    func popPendingTransactions() -> [WCPendingTransaction] {
        defer {
            pendingTransactions = []
        }
        return pendingTransactions
    }

}
