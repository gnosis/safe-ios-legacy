//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

open class AccountUpdateDomainService {

    public init() {}

    open func updateAccountsBalances() {
        precondition(!Thread.isMainThread)

    }

    open func updateAccountBalance(accountID: AccountID) {
        precondition(!Thread.isMainThread)

    }

}
