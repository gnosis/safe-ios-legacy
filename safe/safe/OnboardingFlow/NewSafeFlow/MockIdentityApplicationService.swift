//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessApplication
import CommonTestSupport

class MockIdentityApplicationService: IdentityApplicationService {
    
    var shouldThrow = false

    override func getOrCreateDraftSafe() throws -> DraftSafe {
        if shouldThrow { throw TestError.error }
        return try super.getOrCreateDraftSafe()
    }

}
