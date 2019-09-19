//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol RBETransactionMonitorRepository {

    func save(_ entry: RBETransactionMonitorEntry)
    func remove(_ entry: RBETransactionMonitorEntry)
    func find(id: TransactionID) -> RBETransactionMonitorEntry?
    func findAll() -> [RBETransactionMonitorEntry]

}
