//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Reprsents collection of all Transaction entities
public protocol TransactionRepository {

    /// Persists a transaction
    ///
    /// - Parameter transaction: transaction to save
    func save(_ transaction: Transaction)

    /// Removes transaction from the collection
    ///
    /// - Parameter transaction: transaction to remove
    func remove(_ transaction: Transaction)

    /// Searches a transaction by its identifier
    ///
    /// - Parameter transactionID: transaction or nil if it was not found
    func findByID(_ transactionID: TransactionID) -> Transaction?

    /// Searches a transaction by its hash and status
    ///
    /// - Parameter hash: hash of a transaction
    /// - Parameter status: status of a transaction
    /// - Returns: transaction found or nil otherwise
    func findBy(hash: Data, status: TransactionStatus) -> Transaction?

    /// Generates new transaction identifier
    ///
    /// - Returns: new transaction identifier
    func nextID() -> TransactionID

}
