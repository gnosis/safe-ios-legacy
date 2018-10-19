//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol SynchronisationDomainService {

    func sync()
    func syncTransactions()
    func stopSyncTransactions()

}
