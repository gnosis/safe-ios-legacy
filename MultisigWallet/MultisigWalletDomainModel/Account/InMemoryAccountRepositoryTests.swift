//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel

class InMemoryAccountRepositoryTests: XCTestCase {

    func test_saveFindRemove() throws {
        let repository = InMemoryAccountRepository()
        let walletID = WalletID()
        let account = Account(tokenID: Token.gno.id, walletID: walletID, balance: 0)
        account.add(amount: 100)
        repository.save(account)
        let gnoAccountId = AccountID(tokenID: Token.gno.id, walletID: walletID)
        XCTAssertEqual(repository.find(id: gnoAccountId, walletID: walletID), account)
        let account2 = Account(tokenID: Token.mgn.id, walletID: walletID, balance: nil)
        repository.save(account2)

        let all = repository.all()
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(Set([account, account2]), Set(all))

        repository.remove(account)
        XCTAssertNil(repository.find(id: gnoAccountId, walletID: walletID))
    }

}
