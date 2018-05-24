//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol BlockchainDomainService {

    func generateExternallyOwnedAccount() throws -> String

}
