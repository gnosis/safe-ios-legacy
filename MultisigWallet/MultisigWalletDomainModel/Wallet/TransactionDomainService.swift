//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class TransactionDomainService {

    public init() {}

    public func removeDraftTransaction(_ id: TransactionID) {
        let repository = DomainRegistry.transactionRepository
        if let transaction = repository.findByID(id), transaction.status == .draft {
            repository.remove(transaction)
        }
    }

}
