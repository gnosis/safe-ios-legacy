//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public final class MockAccountUpdateService: AccountUpdateDomainService {

    public var didUpdateBalances = false
    public override func updateAccountsBalances() throws {
        didUpdateBalances = true
        try super.updateAccountsBalances()
    }

    public var updateAccountBalance_input: Token?
    public override func updateAccountBalance(token: Token) throws {
        updateAccountBalance_input = token
        try super.updateAccountBalance(token: token)
    }

}
