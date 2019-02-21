//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct RBETransactionMonitorEntry: Equatable {

    public var transactionID: TransactionID
    public var createdDate: Date

    public init(transactionID: TransactionID, createdDate: Date) {
        self.transactionID = transactionID
        self.createdDate = createdDate
    }

}
