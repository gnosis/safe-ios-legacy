//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol TransactionHistoryDomainService {

    /// Get information about Safes with a provided owner.
    /// - Parameter owner: owner address
    func safes(by owner: Address) throws -> [String]

}
