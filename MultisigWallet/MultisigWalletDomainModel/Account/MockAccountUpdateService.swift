//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public final class MockAccountUpdateService: AccountUpdateDomainService {

    public var didUpdateBalances = false
    public override func updateAccountsBalances() {
        didUpdateBalances = false
        super.updateAccountsBalances()
    }

    public var updateAccountBalance_input: Token?
    public override func updateAccountBalance(token: Token) {
        updateAccountBalance_input = token
        super.updateAccountBalance(token: token)
    }

}
