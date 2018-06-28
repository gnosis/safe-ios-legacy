//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol TransactionRepository {

    func save(_ transaction: Transaction) throws
    func remove(_ transaction: Transaction) throws
    func findByID(_ transactionID: TransactionID) throws -> Transaction?
    func nextID() -> TransactionID

}
