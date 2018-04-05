//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

class AccessApplicationService {

    let account: AccountProtocol

    var blockedPeriodDuration: TimeInterval { return account.blockedPeriodDuration }

    init(account: AccountProtocol) {
        self.account = account
    }

    func hasAccess() -> Bool {
        return account.hasMasterPassword && !account.isSessionActive
    }

    func hasPrimaryUser() -> Bool {
        return account.hasMasterPassword
    }

}
