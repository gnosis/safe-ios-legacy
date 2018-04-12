//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessApplication

class MockIdentityApplicationService: IdentityApplicationService {

    private var recoverySet = false

    override var isRecoverySet: Bool { return recoverySet }

    func setUpRecovery() {
        recoverySet = true
    }
}
