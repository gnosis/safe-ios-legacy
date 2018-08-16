//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel

class InMemoryAccountRepositoryTests: XCTestCase {

    func test_saveFindRemove() throws {
        let repository = InMemoryAccountRepository()
        let account = Account(id: AccountID("0x0"),
                              walletID: WalletID(),
                              balance: 0)
        account.add(amount: 100)
        repository.save(account)
        XCTAssertEqual(repository.find(id: AccountID("0x0"), walletID: account.walletID), account)
        repository.remove(account)
        XCTAssertNil(repository.find(id: AccountID("0x0"), walletID: account.walletID))
    }

}
