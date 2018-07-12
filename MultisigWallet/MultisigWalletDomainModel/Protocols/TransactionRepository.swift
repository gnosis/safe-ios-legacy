//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol TransactionRepository {

    func save(_ transaction: Transaction)
    func remove(_ transaction: Transaction)
    func findByID(_ transactionID: TransactionID) -> Transaction?
    func nextID() -> TransactionID

}
