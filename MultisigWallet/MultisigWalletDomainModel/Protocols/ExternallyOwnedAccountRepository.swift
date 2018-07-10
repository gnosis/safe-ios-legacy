//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol ExternallyOwnedAccountRepository {

    func save(_ account: ExternallyOwnedAccount) throws
    func remove(address: Address) throws
    func find(by address: Address) throws -> ExternallyOwnedAccount?

}
