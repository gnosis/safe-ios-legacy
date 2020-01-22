//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation

// protocol for the service returning incoming and outgoing transactions

public protocol SafeTransactionDomainService {

    func transactions(safe: Address) -> [Transaction]

}
