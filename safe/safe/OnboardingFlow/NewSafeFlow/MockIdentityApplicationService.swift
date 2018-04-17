//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel
import IdentityAccessApplication
import CommonTestSupport

class MockIdentityApplicationService: IdentityApplicationService {
    
    var shouldThrow = false

    override func getOrCreateEOA() throws -> ExternallyOwnedAccount {
        if shouldThrow { throw TestError.error }
        return try super.getOrCreateEOA()
    }

}
