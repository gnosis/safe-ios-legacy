//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public struct WCPendingTransaction {

    public var transactionID: TransactionID
    public var sessionData: WCSessionData
    /// should return submitted transaction hash or error
    public var completion: (Result<String, Error>) -> Void

    init(transactionID: TransactionID,
         sessionData: WCSessionData,
         completion: @escaping (Result<String, Error>) -> Void) {
        self.transactionID = transactionID
        self.sessionData = sessionData
        self.completion = completion
    }

}

final class WCPendingTransactionsRepository {

    private var pendingTransactions = [WCPendingTransaction]()

    func add(_ transaction: WCPendingTransaction) {
        pendingTransactions.append(transaction)
    }

    func popAll() -> [WCPendingTransaction] {
        defer {
            pendingTransactions = []
        }
        return pendingTransactions
    }

}
